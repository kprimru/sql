USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SATISFACTION_QUESTION_INSERT]
	@TEXT	VARCHAR(500),
	@SINGLE	BIT,
	@BOLD	BIT,
	@ORDER	INT,
	@ACTIVE	BIT,
	@ID	UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.SatisfactionQuestion(SQ_TEXT, SQ_SINGLE, SQ_BOLD, SQ_ORDER, SQ_ACTIVE)
			OUTPUT INSERTED.SQ_ID INTO @TBL
			VALUES(@TEXT, @SINGLE, @BOLD, @ORDER, @ACTIVE)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_QUESTION_INSERT] TO rl_satisfaction_i;
GO