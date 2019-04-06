USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EVENT_FILTER]
	@TYPE INT,
	@SERVICE INT,
	@MANAGER INT,
	@BEGIN SMALLDATETIME,
	@END SMALLDATETIME,
	@TEXT VARCHAR(MAX) = NULL, /* текст для поиска в комментариях */
	@FLAG BIT = NULL, /* если 1 - то логическое И, если 0 - то ИЛИ */
	@CLEAR	BIT	=	 NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;	

	IF OBJECT_ID('tempdb..#words') IS NOT NULL
		DROP TABLE #words

	CREATE TABLE #words
		(
			WRD	VARCHAR(100) PRIMARY KEY
		)
		
	IF @TEXT IS NOT NULL
		INSERT INTO #words(WRD)
			SELECT DISTINCT '%' + Word + '%'
			FROM dbo.SplitString(@TEXT)

	IF @TEXT IS NULL
	BEGIN
		SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
		FROM 
			dbo.ClientReadList()
			INNER JOIN dbo.EventTable a ON ClientID = RCL_ID 
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID 
			INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 		
		WHERE EventActive = 1 
			AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
			AND (EventDate <= @END OR @END IS NULL)
			AND (LTRIM(RTRIM(EventComment)) = '' OR @CLEAR <> 1)
		ORDER BY EventDate DESC, ServiceName, ClientFullName
	END
	ELSE
	BEGIN
		IF @FLAG = 1
			SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
			FROM 
				dbo.ClientReadList()
				INNER JOIN dbo.EventTable a ON ClientID = RCL_ID 
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID 
				INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 		
			WHERE EventActive = 1 
				AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
				AND (EventDate <= @END OR @END IS NULL)
				AND (LTRIM(RTRIM(EventComment)) = '' OR @CLEAR <> 1)
				AND NOT EXISTS
					(
						SELECT *
						FROM #words
						WHERE NOT (EventComment LIKE WRD)
					)	
			ORDER BY EventDate DESC, ServiceName, ClientFullName
		ELSE
			SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
			FROM 
				dbo.ClientReadList()
				INNER JOIN dbo.EventTable a ON ClientID = RCL_ID 
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID 
				INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 		
			WHERE EventActive = 1 
				AND (a.EventTypeID = @TYPE OR @TYPE IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (EventDate >= @BEGIN OR @BEGIN IS NULL)
				AND (EventDate <= @END OR @END IS NULL)
				AND (LTRIM(RTRIM(EventComment)) = '' OR @CLEAR <> 1)
				AND EXISTS
					(
						SELECT *
						FROM #words
						WHERE EventComment LIKE WRD
					)	
			ORDER BY EventDate DESC, ServiceName, ClientFullName
	END
	
	IF OBJECT_ID('tempdb..#words') IS NOT NULL
		DROP TABLE #words

	/*
	DECLARE @SBEGIN VARCHAR(20)
	DECLARE @SEND VARCHAR(20)

	SET @SBEGIN = CONVERT(VARCHAR(20), @BEGIN, 112)
	SET @SEND = CONVERT(VARCHAR(20), @END, 112)

	DECLARE @SQL NVARCHAR(MAX)
	SET @SQL = N'

	SELECT EventID, ClientFullName, EventDate AS EventDateStr, EventTypeName, EventComment, ServiceName, ManagerName, a.ClientID, EventDate
	FROM 
		dbo.ClientReadList()
		INNER JOIN dbo.EventTable a ON ClientID = RCL_ID 
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID 
		INNER JOIN dbo.EventTypeTable c ON a.EventTypeID = c.EventTypeID 		
	WHERE EventActive = 1 '

	IF @TYPE IS NOT NULL
		SET @SQL = @SQL + ' AND a.EventTypeID = @TYPE '
	IF @SERVICE IS NOT NULL
		SET @SQL = @SQL + ' AND ServiceID = @SERVICE '
	IF @MANAGER IS NOT NULL
		SET @SQL = @SQL + ' AND ManagerID = @MANAGER '
	IF @BEGIN IS NOT NULL
		SET @SQL = @SQL + ' AND EventDate >= @BEGIN '
	IF @END IS NOT NULL
		SET @SQL = @SQL + ' AND EventDate <= @END '
	IF @CLEAR = 1
		SET @SQL = @SQL + ' AND LTRIM(RTRIM(EventComment)) = '''''

	PRINT @SQL

	IF @TEXT IS NOT NULL AND @FLAG IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND ('

		SELECT 
			@SQL = @SQL + 
						' EventComment LIKE ''%' + REPLACE(Item, '*', '%') + '%'' ' + 
						CASE @FLAG 
							WHEN 1 THEN ' AND'
							WHEN 0 THEN ' OR'
							ELSE ' OR'
						END
		FROM dbo.GetTableList(@TEXT)
			
		SET @SQL = LEFT(@SQL, LEN(@SQL) - 3)

		SET @SQL = @SQL + ')'
	END

	SET @SQL = @SQL + '
	ORDER BY EventDate DESC, ServiceName, ClientFullName'

	EXEC sp_executesql @SQL, N'@TYPE INT, @SERVICE INT, @MANAGER INT, @BEGIN VARCHAR(20), @END VARCHAR(20)',
		@TYPE, @SERVICE, @MANAGER, @SBEGIN, @SEND		
	*/
END