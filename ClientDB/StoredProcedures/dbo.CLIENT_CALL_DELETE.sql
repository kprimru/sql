USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CALL_DELETE]
	@ID			UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

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
END