USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_LAST_EVENT_SELECT]
	@MON_COUNT	TINYINT,
	@MANAGER	VARCHAR(MAX)	=	NULL,
	@SERVICE	INT	=	NULL,
	@TYPE		VARCHAR(MAX) = '1,2,3,4,6',
	@MON_EQUAL	BIT =	0,
	@SERVICE_EVENT	BIT	=	0,
	@CL_TYPE	VARCHAR(MAX) = NULL,
	@CATEGORY	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#event') IS NOT NULL
		DROP TABLE #event

	CREATE TABLE #event 
		(
			ClientID	INT PRIMARY KEY,
			EventDate	SMALLDATETIME,
			Author		NVARCHAR(128),
			EventText	VARCHAR(MAX),
			ClientTypeID	TinyInt
		)
	
	IF OBJECT_ID('tempdb..#last_event') IS NOT NULL
		DROP TABLE #last_event

	CREATE TABLE #last_event
		(
			EventID		INT,
			ClientTypeID	TinyInt
		)

	IF @SERVICE_EVENT = 1	
		INSERT INTO #last_event(EventID, ClientTypeID)
			SELECT
				(
					SELECT TOP 1 EventID
					FROM 
						dbo.EventTable b INNER JOIN
						dbo.ServiceTable ON EventCreateUser = ServiceLogin
					WHERE a.ClientID = b.ClientID AND EventActive = 1
					ORDER BY EventDate DESC, EventID DESC
				), b.ClientTypeID
		FROM 
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			INNER JOIN 
				(
					SELECT ID 
					FROM dbo.TableIDFromXML(@TYPE)
				) AS c ON a.ServiceTypeID = c.ID
			INNER JOIN 
				(
					SELECT ID 
					FROM dbo.TableIDFromXML(@CL_TYPE)
				) AS d ON b.ClientContractTypeID = d.ID
		WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXml(@MANAGER)) OR @MANAGER IS NULL)
			AND (@CATEGORY IS NULL OR b.ClientTypeID IN (SELECT ID FROM dbo.TableIDFromXml(@CATEGORY)))
			
	ELSE
		INSERT INTO #last_event(EventID, ClientTypeID)
			SELECT
				(
					SELECT TOP 1 EventID
					FROM 
						dbo.EventTable b 
					WHERE a.ClientID = b.ClientID AND EventActive = 1
					ORDER BY EventDate DESC, EventID DESC
				), ClientTypeID
		FROM 
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			INNER JOIN 
				(
					SELECT ID 
					FROM dbo.TableIDFromXML(@TYPE)
				) AS c ON a.ServiceTypeID = c.ID
			INNER JOIN 
				(
					SELECT ID 
					FROM dbo.TableIDFromXML(@CL_TYPE)
				) AS d ON b.ClientContractTypeID = d.ID
		WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXml(@MANAGER)) OR @MANAGER IS NULL)
			AND (@CATEGORY IS NULL OR b.ClientTypeID IN (SELECT ID FROM dbo.TableIDFromXml(@CATEGORY)))
		
	
	INSERT INTO #event(ClientID, EventDate, Author, EventText, ClientTypeID)
		SELECT ClientID, EventDate, EventCreateUser, EventComment, ClientTypeID
		FROM 
			#last_event a
			INNER JOIN dbo.EventTable b ON a.EventID = b.EventID
			

    SELECT 
		a.ClientID,
		ManagerName, ServiceName, ClientFullName, CATEGORY = c.ClientTypeName,
		EventDate AS MaxDate,
		DATEDIFF(MONTH, EventDate, GETDATE()) AS DIFF_DATA,
		ISNULL(Author, '') + ' / ' + CONVERT(VARCHAR(20), EventDate, 104) + CHAR(10) + ISNULL(EventText, '') AS EventComment
	FROM 
		dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN	#event t ON t.ClientID = a.ClientID
		LEFT JOIN dbo.ClientTypeTable c ON c.ClientTypeID = t.ClientTypeID
	WHERE 
		(@MON_EQUAL = 0 AND DATEADD(MONTH, @MON_COUNT, EventDate) < GETDATE())
		OR (@MON_EQUAL = 1 AND dbo.MonthOf(DATEADD(MONTH, @MON_COUNT, EventDate)) = dbo.MonthOf(GETDATE()))
	ORDER BY ManagerName, ServiceName, ClientFullName

	IF OBJECT_ID('tempdb..#event') IS NOT NULL
		DROP TABLE #event

	IF OBJECT_ID('tempdb..#last_event') IS NOT NULL
		DROP TABLE #last_event
END