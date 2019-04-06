USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EVENT_SELECT]
	@CLIENT	INT,
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@TEXT	VARCHAR(100) = NULL,
	@DELETED	BIT = 0,
	@TYPE	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT 
		EventID, EventDate, EventComment, 
		EventTypeName, a.EventTypeID,
		EventCreate, EventCreateUser, 
		EventLastUpdate, EventLastUpdateUser,
		EventCreateUser + ' ' + CONVERT(VARCHAR(20), EventCreate, 104) + ' ' + CONVERT(VARCHAR(20), EventCreate, 108) AS EventCreateData,
		EventLastUpdateUser + ' ' + CONVERT(VARCHAR(20), EventLastUpdate, 104) + ' ' + CONVERT(VARCHAR(20), EventLastUpdate, 108) AS EventLastUpdateData,
		(
			SELECT COUNT(*)
			FROM dbo.EventTable c
			WHERE c.MasterID = a.MasterID
		) AS EventCount, 1 AS EventStatus,
		--DATEDIFF(DAY, EventCreate, GETDATE()) AS CreateDelta
		CASE WHEN DATEDIFF(DAY, EventCreate, GETDATE()) <= 7 THEN 0 ELSE DATEDIFF(DAY, EventCreate, GETDATE()) END AS CreateDelta
	FROM
		dbo.EventTable a INNER JOIN
		dbo.EventTypeTable b ON a.EventTypeID = b.EventTypeID
	WHERE ClientID = @CLIENT 
		AND EventActive = 1
		AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
		AND (EventDate <= @END OR @END IS NULL)
		AND (EventComment LIKE @TEXT OR @TEXT IS NULL)
		AND (b.EventTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)) OR @TYPE IS NULL)

	UNION ALL

	SELECT
		EventID, EventDate, EventComment, 
		EventTypeName, a.EventTypeID,
		EventCreate, EventCreateUser, 
		EventLastUpdate, EventLastUpdateUser,
		EventCreateUser + ' ' + CONVERT(VARCHAR(20), EventCreate, 104) + ' ' + CONVERT(VARCHAR(20), EventCreate, 108) AS EventCreateData,
		EventLastUpdateUser + ' ' + CONVERT(VARCHAR(20), EventLastUpdate, 104) + ' ' + CONVERT(VARCHAR(20), EventLastUpdate, 108) AS EventLastUpdateData,
		(
			SELECT COUNT(*)
			FROM dbo.EventTable c
			WHERE c.MasterID = a.MasterID
		) AS EventCount, 0 AS EventStatus,
		--DATEDIFF(DAY, EventCreate, GETDATE()) AS CreateDelta
		CASE WHEN DATEDIFF(DAY, EventCreate, GETDATE()) <= 7 THEN 0 ELSE DATEDIFF(DAY, EventCreate, GETDATE()) END AS CreateDelta
	FROM
		dbo.EventTable a INNER JOIN
		dbo.EventTypeTable b ON a.EventTypeID = b.EventTypeID
	WHERE ClientID = @CLIENT 
		AND (b.EventTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)) OR @TYPE IS NULL)
		AND @DELETED = 1
		AND EventActive = 0
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.EventTable d
				WHERE a.MasterID = d.MasterID
					AND d.EventActive = 1
			)
		AND EventID = 
			(
				SELECT MAX(EventID)
				FROM dbo.EventTable e
				WHERE e.MasterID = a.MasterID
			)
		AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
		AND (EventDate <= @END OR @END IS NULL)
		AND (EventComment LIKE @TEXT OR @TEXT IS NULL)
		
	ORDER BY EventDate DESC, EventLastUpdate DESC
END