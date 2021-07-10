USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_STUDY_LAST]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE
		FROM Subhost.SubhostStudy
		WHERE SS_ID_SUBHOST = @SH_ID AND SS_ID_PERIOD = @PR_ID

		INSERT INTO Subhost.SubhostLessonPrice(SLP_ID_PERIOD, SLP_ID_LESSON, SLP_PRICE)
			SELECT @PR_ID, SLP_ID_LESSON, SLP_PRICE
			FROM Subhost.SubhostLessonPrice a
			WHERE SLP_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)
				AND NOT EXISTS
					(
						SELECT *
						FROM Subhost.SubhostLessonPrice b
						WHERE b.SLP_ID_PERIOD = @PR_ID
							AND b.SLP_ID_LESSON = a.SLP_ID_LESSON
					)

		INSERT INTO Subhost.SubhostStudy(
				SS_ID_SUBHOST, SS_ID_PERIOD, SS_ID_LESSON, SS_COUNT)
			SELECT
				SS_ID_SUBHOST, @PR_ID, SS_ID_LESSON, SS_COUNT
			FROM Subhost.SubhostStudy
			WHERE SS_ID_SUBHOST = @SH_ID AND SS_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_STUDY_LAST] TO rl_subhost_calc;
GO