USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EVENT_HISTORY_GET]
	@EventID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MS INT

	SELECT @MS = MasterID
	FROM dbo.EventTable
	WHERE EventID = @EventID

	SELECT 
		EventDate, EventComment, 
		EventTypeName, 
		EventCreateUser + ' / ' + CONVERT(VARCHAR(20), EventCreate, 104) + ' ' + CONVERT(VARCHAR(20), EventCreate, 108) AS EventCreate, 
		EventLastUpdateUser + ' / ' + CONVERT(VARCHAR(20), EventLastUpdate, 104) + ' ' + CONVERT(VARCHAR(20), EventLastUpdate, 108) AS EventLastUpdate
	FROM 
		dbo.EventTypeTable a 
		INNER JOIN dbo.EventTable b ON a.EventTypeID = b.EventTypeID
	WHERE MasterID = @MS
	ORDER BY EventLastUpdate DESC
END