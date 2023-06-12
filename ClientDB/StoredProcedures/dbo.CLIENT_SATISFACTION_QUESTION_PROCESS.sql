USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_SATISFACTION_QUESTION_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_QUESTION_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_SATISFACTION_QUESTION_PROCESS]
	@CS_ID	UNIQUEIDENTIFIER,
	@SQ_ID	UNIQUEIDENTIFIER,
	@NOTE	VARCHAR(500),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		IF @ID IS NULL
		BEGIN
			INSERT INTO dbo.ClientSatisfactionQuestion(CSQ_ID_CS, CSQ_ID_QUESTION, CSQ_NOTE)
				OUTPUT INSERTED.CSQ_ID INTO @TBL
				VALUES(@CS_ID, @SQ_ID, @NOTE)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
			UPDATE dbo.ClientSatisfactionQuestion
			SET CSQ_NOTE = @NOTE
			WHERE CSQ_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_QUESTION_PROCESS] TO rl_client_call_i;
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_QUESTION_PROCESS] TO rl_client_call_u;
GO
