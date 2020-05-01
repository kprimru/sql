USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_STUDY_SELECT]
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

		SELECT
			LS_ID, LS_NAME,
			(
				SELECT SS_COUNT
				FROM Subhost.SubhostStudy
				WHERE SS_ID_PERIOD = @PR_ID
					AND SS_ID_SUBHOST = @SH_ID
					AND SS_ID_LESSON = LS_ID
			) AS SS_COUNT,
			(
				SELECT SLP_PRICE
				FROM Subhost.SubhostLessonPrice
				WHERE SLP_ID_PERIOD = @PR_ID
					AND SLP_ID_LESSON = LS_ID
			) AS SLP_PRICE,
			(
				SELECT SLP_PRICE
				FROM Subhost.SubhostLessonPrice
				WHERE SLP_ID_PERIOD = @PR_ID
					AND SLP_ID_LESSON = LS_ID
			) AS SLP_ET_PRICE
		FROM
			Subhost.Lesson
		WHERE LS_ACTIVE = 1
		ORDER BY LS_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_STUDY_SELECT] TO rl_subhost_calc;
GO