USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_ANSWER_PROCESS]
	@CSQ_ID	UNIQUEIDENTIFIER,
	@SA_ID	UNIQUEIDENTIFIER,
	@CHECKED	BIT
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

		IF @CHECKED = 0
			DELETE FROM dbo.ClientSatisfactionAnswer 
			WHERE CSA_ID_QUESTION = @CSQ_ID
				AND CSA_ID_ANSWER = @SA_ID
		ELSE
		BEGIN
			INSERT INTO dbo.ClientSatisfactionAnswer(CSA_ID_QUESTION, CSA_ID_ANSWER)
				SELECT @CSQ_ID, @SA_ID
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientSatisfactionAnswer
						WHERE CSA_ID_QUESTION = @CSQ_ID
							AND CSA_ID_ANSWER = @SA_ID
					)
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END