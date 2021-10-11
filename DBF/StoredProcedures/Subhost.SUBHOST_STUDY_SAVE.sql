USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_STUDY_SAVE]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@LS_ID	SMALLINT,
	@COUNT	INT,
	@PRICE	MONEY
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

		IF EXISTS
			(
				SELECT *
				FROM Subhost.SubhostStudy
				WHERE SS_ID_PERIOD = @PR_ID
					AND SS_ID_SUBHOST = @SH_ID
					AND SS_ID_LESSON = @LS_ID
			)
		BEGIN
			UPDATE Subhost.SubhostStudy
			SET SS_COUNT = @COUNT
			WHERE SS_ID_PERIOD = @PR_ID
				AND SS_ID_SUBHOST = @SH_ID
				AND SS_ID_LESSON = @LS_ID
		END
		ELSE
		BEGIN
			INSERT INTO Subhost.SubhostStudy(SS_ID_PERIOD, SS_ID_SUBHOST, SS_ID_LESSON, SS_COUNT)
				SELECT @PR_ID, @SH_ID, @LS_ID, @COUNT
		END

		IF @PRICE IS NOT NULL
		BEGIN
			UPDATE Subhost.SubhostLessonPrice
			SET SLP_PRICE = @PRICE
			WHERE SLP_ID_PERIOD = @PR_ID AND SLP_ID_LESSON = @LS_ID

			IF @@ROWCOUNT = 0
				INSERT INTO Subhost.SubhostLessonPrice(SLP_ID_PERIOD, SLP_ID_LESSON, SLP_PRICE)
					VALUES(@PR_ID, @LS_ID, @PRICE)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_STUDY_SAVE] TO rl_subhost_calc;
GO
