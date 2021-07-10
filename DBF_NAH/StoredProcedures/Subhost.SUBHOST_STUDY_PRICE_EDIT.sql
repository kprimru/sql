USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_STUDY_PRICE_EDIT]
	@PR_ID	SMALLINT,
	@LS_ID	SMALLINT,
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
				FROM Subhost.SubhostLessonPrice
				WHERE SLP_ID_PERIOD = @PR_ID
					AND SLP_ID_LESSON = @LS_ID
			)
		BEGIN
			UPDATE Subhost.SubhostLessonPrice
			SET SLP_PRICE = @PRICE
			WHERE SLP_ID_PERIOD = @PR_ID
				AND SLP_ID_LESSON = @LS_ID
		END
		ELSE
		BEGIN
			INSERT INTO Subhost.SubhostLessonPrice(SLP_ID_PERIOD, SLP_ID_LESSON, SLP_PRICE)
				SELECT @PR_ID, @LS_ID, @PRICE
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
GRANT EXECUTE ON [Subhost].[SUBHOST_STUDY_PRICE_EDIT] TO rl_subhost_calc;
GO