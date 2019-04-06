USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT,
	@TYPE		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	IF OBJECT_ID('tempdb..#service') IS NOT NULL
		DROP TABLE #service

	CREATE TABLE #service(SR_ID INT PRIMARY KEY)

	INSERT INTO #service(SR_ID)
		SELECT ServiceID
		FROM dbo.ServiceTable
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
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


	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client (CL_ID INT PRIMARY KEY, ServiceID INT)

	INSERT INTO #client
		(
			CL_ID, ServiceID
		)
		SELECT ClientID, ClientServiceID
		FROM 
			dbo.ClientTable
			INNER JOIN #service ON ClientServiceID = SR_ID
			INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
		WHERE StatusID = 2 AND STATUS = 1

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