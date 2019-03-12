USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CARD_CHECK]
	@SERVICE	INT = NULL,
	@MANAGER	NVARCHAR(MAX) = NULL,
	@TP			NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MNGR TABLE(ID INT)
	
	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL
	
	IF @MANAGER IS NULL
		INSERT INTO @MNGR(ID)
			SELECT ManagerID
			FROM dbo.ManagerTable
	ELSE
		INSERT INTO @MNGR(ID)
			SELECT ID
			FROM dbo.TableIDFromXML(@MANAGER)
				
	DECLARE @type TABLE (ETP VARCHAR(50))
	
	INSERT INTO @type(ETP)
		SELECT ID
		FROM dbo.TableStringFromXML(@TP)	

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
		
	CREATE TABLE #client 
		(
			CL_ID INT PRIMARY KEY, 
			ClientFullName VARCHAR(255), 
			ServiceName VARCHAR(150), 
			ManagerName VARCHAR(150),
			ConnectDate	SMALLDATETIME
		)

	INSERT INTO #client(CL_ID, ClientFullName, ServiceName, ManagerName, ConnectDate)
		SELECT b.ClientID, ClientFullName, ServiceName, ManagerName, ConnectDate
		FROM 
			dbo.ClientReadList() a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON RCL_ID = ClientID
			INNER JOIN @MNGR z ON b.ManagerID = z.ID
			LEFT OUTER JOIN
				(
					SELECT ClientID, MIN(ConnectDate) AS ConnectDate
					FROM dbo.ClientConnectView WITH(NOEXPAND)
					GROUP BY ClientID				
				) AS o_O ON o_O.ClientID = b.ClientID
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)

	/*
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result

	CREATE TABLE #result
		(
			ClientID	INT,
			ClientFullName	VARCHAR(255),
			ManagerName		VARCHAR(150),
			ServiceName		VARCHAR(150),
			ER				VARCHAR(100),
			ConnectDate		SMALLDATETIME
		)
	*/	
	

	SELECT b.ClientID, a.ClientFullName, ManagerName, ServiceName, ER, ConnectDate
	FROM
		#client a
		INNER JOIN dbo.ClientCheckView b ON a.CL_ID = b.ClientID
		INNER JOIN @type ON TP = ETP			
	ORDER BY ManagerName, ServiceName, ClientFullName
	/*
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
	*/	
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END