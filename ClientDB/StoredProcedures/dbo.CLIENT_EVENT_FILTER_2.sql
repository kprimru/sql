USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EVENT_FILTER_2]
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@CLIENT		NVARCHAR(256),
	@TYPE		NVARCHAR(MAX),
	@SERVICE	INT,
	@AUTHOR		NVARCHAR(MAX),
	@WORDS		NVARCHAR(MAX),
	@CATEGORY	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @START IS NULL
		SET @START = dbo.DateOf(DATEADD(MONTH, -2, GETDATE()))

	IF OBJECT_ID('tempdb..#words') IS NOT NULL
		DROP TABLE #words

	CREATE TABLE #words
		(
			WRD	VARCHAR(100) PRIMARY KEY
		)
			
	INSERT INTO #words(WRD)
		SELECT DISTINCT '%' + Word + '%'
		FROM dbo.SplitString(@WORDS)
		WHERE Word IS NOT NULL
		
	SELECT 
		c.ClientID, EventDate, ClientFullName, ServiceName, ManagerName, ServiceStatusIndex, CATEGORY, EventTypeName, EventComment,
		EventCreateUser AS EventCreateData, 
		CASE
			WHEN EventLastUpdate <> EventCreate THEN EventLastUpdateUser 
			ELSE ''
		END AS EventlastUpdateData
	FROM
		dbo.ClientReadList() a
		INNER JOIN dbo.EventTable b ON a.RCL_ID = b.CLientID
		INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ClientID = c.ClientID
		INNER JOIN dbo.EventTypeTable e ON e.EventTypeID = b.EventTypeID
		LEFT OUTER JOIN dbo.ClientTypeAllView d ON d.ClientID = c.ClientID
	WHERE /*EventID = MasterID
		AND */EventActive = 1
		AND (EventDate >= @START OR @START IS NULL)
		AND (EventDate <= @FINISH OR @FINISH IS NULL)
		AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (@TYPE IS NULL OR b.EventTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)))
		AND (@AUTHOR IS NULL OR b.EventCreateUser IN (SELECT ID FROM dbo.TableStringFromXML(@AUTHOR)))
		AND (@CATEGORY IS NULL OR CATEGORY IN (SELECT ID FROM dbo.TableStringFromXML(@CATEGORY)))
		AND NOT EXISTS
			(
				SELECT *
				FROM #words
				WHERE NOT (EventComment LIKE WRD)
			)	
	ORDER BY EventDate DESC, EventID DESC
		
	IF OBJECT_ID('tempdb..#words') IS NOT NULL
		DROP TABLE #words
END
