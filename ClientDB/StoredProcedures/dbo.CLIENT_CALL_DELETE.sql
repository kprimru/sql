USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CALL_DELETE]
	@ID			UNIQUEIDENTIFIER
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

		DELETE FROM dbo.ClientDutyControl
		WHERE CDC_ID_CALL = @ID

		DELETE FROM dbo.ClientTrust
		WHERE CT_ID_CALL = @ID

		DELETE FROM dbo.ClientSatisfactionAnswer
		WHERE CSA_ID_QUESTION IN
			(
				SELECT CSQ_ID
				FROM dbo.ClientSatisfactionQuestion
				WHERE CSQ_ID_CS IN
					(
						SELECT CS_ID
						FROM dbo.ClientSatisfaction
						WHERE CS_ID_CALL = @ID
					)
			)

		DELETE
		FROM dbo.ClientSatisfactionQuestion
		WHERE CSQ_ID_CS IN
			(
				SELECT CS_ID
				FROM dbo.ClientSatisfaction
				WHERE CS_ID_CALL = @ID
			)

		DELETE
		FROM dbo.ClientSatisfaction
		WHERE CS_ID_CALL = @ID

		DELETE FROM dbo.ClientCall
		WHERE CC_ID = @ID

		DELETE FROM Poll.ClientPollAnswer
		WHERE ID_QUESTION IN
			(
				SELECT ID
				FROM Poll.ClientPollQuestion
				WHERE ID_POLL IN
					(
						SELECT ID
						FROM Poll.ClientPoll
						WHERE ID_CALL = @ID
					)
			)

		DELETE
		FROM Poll.ClientPollQuestion
		WHERE ID_POLL IN
			(
				SELECT ID
				FROM Poll.ClientPoll
				WHERE ID_CALL = @ID
			)

		DELETE
		FROM Poll.ClientPoll
		WHERE ID_CALL = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_CALL_DELETE] TO rl_client_call_d;
GO