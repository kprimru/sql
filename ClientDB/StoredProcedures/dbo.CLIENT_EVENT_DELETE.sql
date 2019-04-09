USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EVENT_DELETE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.EventTable
		(
			ClientID, MasterID, EventDate, EventComment, EventTypeID, EventActive,
			EventCreate, EventLastUpdate, EventCreateUser, EventLastUpdateUser
		)
		SELECT 
			ClientID, MasterID, EventDate, EventComment, EventTypeID, 0,
			EventCreate, GETDATE(), EventCreateUser, ORIGINAL_LOGIN()
		FROM dbo.EventTable
		WHERE EventID = @ID
		
	UPDATE dbo.EventTable
	SET EventActive = 0
	WHERE EventID = @ID	
END