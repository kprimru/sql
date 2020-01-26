USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_SEARCH_SELECT]
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
						dbo.ClientTable a
						INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
						INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
					WHERE ClientServiceID = ServiceID
						AND STATUS = 1
				)


	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client (CL_ID INT PRIMARY KEY, ServiceID INT)

	INSERT INTO #client
		(
			CL_ID, ServiceID
		)
		SELECT ClientID, ClientServiceID
		FROM 
			dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN #service ON ClientServiceID = SR_ID
			INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
		WHERE STATUS = 1
			AND EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
				)

	IF OBJECT_ID('tempdb..#rate') IS NOT NULL
		DROP TABLE #rate

	CREATE TABLE #rate
		(
			SR_ID			INT PRIMARY KEY,
			SearchClient	INT,
			TotalClient		INT
		)

	INSERT INTO #rate
		(
			SR_ID, SearchClient, TotalClient
		)
		SELECT 
			SR_ID,
			(
				SELECT COUNT(DISTINCT CL_ID)
				FROM 
					#client					
					INNER JOIN dbo.ClientSearchTable y ON ClientID = CL_ID
				WHERE SearchGetDay BETWEEN @BEGIN AND @END 
					AND ServiceID = SR_ID
			),
			(
				SELECT COUNT(*)
				FROM 
					#client
				WHERE ServiceID = SR_ID
			)
		FROM #service

	SELECT 
		@TOTAL = CONVERT(VARCHAR(20), SUM(SearchClient)) + ' из ' + CONVERT(VARCHAR(20), SUM(TotalClient)),
		@TOTAL_PER = CONVERT(VARCHAR(20), CONVERT(DECIMAL(6, 2), ROUND(100 * CONVERT(DECIMAL(8, 4), SUM(SearchClient)) / SUM(TotalClient), 2)))
	FROM #rate

	SELECT 
		ServiceID, ManagerName, ServiceName,
		CONVERT(VARCHAR(20), SearchClient) + ' из ' + CONVERT(VARCHAR(20), TotalClient) AS ServiceCount,
		ROUND(100 * CONVERT(DECIMAL(8, 4), SearchClient) / TotalClient, 2) AS ServiceRate
	FROM 
		#rate
		INNER JOIN dbo.ServiceTable a ON SR_ID = ServiceID
		INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
	WHERE TotalClient <> 0
	ORDER BY ServiceName	

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	IF OBJECT_ID('tempdb..#service') IS NOT NULL
		DROP TABLE #service

	IF OBJECT_ID('tempdb..#rate') IS NOT NULL
		DROP TABLE #rate
END