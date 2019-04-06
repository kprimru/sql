USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_PERIODICITY_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	VARCHAR(MAX),
	@TYPE		VARCHAR(MAX),
	@TOTAL		VARCHAR(30) = NULL OUTPUT,
	@TOTAL_PER	VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	IF @MANAGER IS NULL
	BEGIN	
		SET @MANAGER = '<LIST>'

		SELECT @MANAGER = @MANAGER + '<ITEM>' + CONVERT(VARCHAR(20), ManagerID) + '</ITEM>'
		FROM dbo.ManagerTable

		SET @MANAGER = @MANAGER + '</LIST>'
	END


	DECLARE @SQL VARCHAR(MAX)

	DECLARE @WEEK TABLE (WEEK_ID SMALLINT, WBEGIN SMALLDATETIME, WEND SMALLDATETIME)

	INSERT INTO @WEEK(WEEK_ID, WBEGIN, WEND)
		SELECT WEEK_ID, WBEGIN, WEND 
		FROM dbo.WeekDates(@BEGIN, @END)


	IF OBJECT_ID('tempdb..#service') IS NOT NULL
		DROP TABLE #service

	CREATE TABLE #service(SR_ID INT PRIMARY KEY)

	INSERT INTO #service(SR_ID)
		SELECT ServiceID
		FROM 
			dbo.ServiceTable
			INNER JOIN dbo.TableIDFromXML(@MANAGER) ON ID = ManagerID 
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			/*AND (ManagerID = @MANAGER OR @MANAGER IS NULL)*/
			AND EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientTable
						INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
					WHERE StatusID = 2
						AND ClientServiceID = ServiceID
						AND STATUS = 1
				)


	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY, SR_ID INT)
		
	INSERT INTO #clientlist(CL_ID, SR_ID)
		SELECT ClientID, ClientServiceID
		FROM 
			dbo.ClientTable a
			INNER JOIN #service ON ClientServiceID = SR_ID
			INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
		WHERE StatusID = 2 
			AND STATUS = 1
			AND EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
				)

	IF OBJECT_ID('tempdb..#weekupdate') IS NOT NULL
		DROP TABLE #weekupdate

	CREATE TABLE #weekupdate
		(
			CL_ID	INT,
			WEEK_ID	SMALLINT,
			UPD_CNT	SMALLINT
		)

	INSERT INTO #weekupdate(CL_ID, WEEK_ID, UPD_CNT)
		SELECT 
			CL_ID, WEEK_ID, 
			(
				SELECT COUNT(*)
				FROM USR.USRIBDateView WITH(NOEXPAND) 
				WHERE UD_ID_CLIENT = CL_ID 
					AND UIU_DATE_S BETWEEN WBEGIN AND WEND
			)
		FROM 
			#clientlist
			CROSS JOIN @WEEK

	SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #weekupdate (CL_ID, WEEK_ID)'
	EXEC (@SQL)

	DECLARE @WEEK_COUNT	SMALLINT

	SELECT @WEEK_COUNT = COUNT(*)
	FROM @WEEK

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client 
			(
				CL_ID		INT PRIMARY KEY, 
				ServiceID	INT,
				UpdateCount	INT,
				WeekCount	INT
			)	

	INSERT INTO #client
		(
			CL_ID, ServiceID, UpdateCount, WeekCount
		)
		SELECT 
			ClientID, ClientServiceID,
			(
				SELECT COUNT(*)
				FROM #weekupdate
				WHERE ClientID = CL_ID
					AND UPD_CNT <> 0
			),
			@WEEK_COUNT
		FROM 
			#clientlist
			INNER JOIN dbo.ClientTable ON ClientID = CL_ID

	IF OBJECT_ID('tempdb..#rate') IS NOT NULL
		DROP TABLE #rate

	CREATE TABLE #rate
		(
			SR_ID			INT PRIMARY KEY,
			NormalCount		INT,
			TotalCount		INT
		)

	INSERT INTO #rate
		(
			SR_ID, NormalCount, TotalCount
		)
		SELECT 
			SR_ID,
			(
				SELECT COUNT(*)
				FROM #client
				WHERE ServiceID = SR_ID
					AND UpdateCount = WeekCount
			),
			(
				SELECT COUNT(*)
				FROM #client
				WHERE ServiceID = SR_ID
			)
		FROM #service

	SELECT 
		@TOTAL = CONVERT(VARCHAR(20), SUM(NormalCount)) + ' из ' + CONVERT(VARCHAR(20), SUM(TotalCount)),
		@TOTAL_PER = CONVERT(VARCHAR(20), CONVERT(DECIMAL(6, 2), ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(NormalCount)) / SUM(TotalCount), 2)))
	FROM #rate

	SELECT 
		ServiceID, ManagerName, ServiceName,
		CONVERT(VARCHAR(20), NormalCount) + ' из ' + CONVERT(VARCHAR(20), TotalCount) AS ServiceCount,
		ROUND(100 * CONVERT(DECIMAL(8, 4), NormalCount) / TotalCount, 2) AS ServiceRate
	FROM 
		#rate
		INNER JOIN dbo.ServiceTable a ON SR_ID = ServiceID
		INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
	WHERE TotalCount <> 0
	ORDER BY ServiceName	

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	IF OBJECT_ID('tempdb..#service') IS NOT NULL
		DROP TABLE #service

	IF OBJECT_ID('tempdb..#rate') IS NOT NULL
		DROP TABLE #rate

	IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
		DROP TABLE #clientlist

	IF OBJECT_ID('tempdb..#weekupdate') IS NOT NULL
		DROP TABLE #weekupdate
END