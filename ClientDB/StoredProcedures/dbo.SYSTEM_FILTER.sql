USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_FILTER]
	@SYSTEM	VARCHAR(MAX) = NULL,
	@TYPE	VARCHAR(MAX) = NULL,
	@NET	VARCHAR(MAX) = NULL,
	@STATUS	VARCHAR(MAX) = NULL,
	@SERVICE	VARCHAR(MAX) = NULL,
	@MANAGER	VARCHAR(MAX) = NULL,
	@CNT	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF OBJECT_ID('tempdb..#system') IS NOT NULL
			DROP TABLE #system
		IF OBJECT_ID('tempdb..#type') IS NOT NULL
			DROP TABLE #type
		IF OBJECT_ID('tempdb..#net') IS NOT NULL
			DROP TABLE #net
		IF OBJECT_ID('tempdb..#status') IS NOT NULL
			DROP TABLE #status
		IF OBJECT_ID('tempdb..#service') IS NOT NULL
			DROP TABLE #service
		IF OBJECT_ID('tempdb..#manager') IS NOT NULL
			DROP TABLE #manager
		
		CREATE TABLE #system
			(
				SystemID	INT PRIMARY KEY
			)

		IF @SYSTEM IS NULL
			INSERT INTO #system(SystemID)
				SELECT SystemID
				FROM dbo.SystemTable
		ELSE
			INSERT INTO #system(SystemID)
				SELECT ID
				FROM dbo.TableIDFromXML(@SYSTEM)

		CREATE TABLE #type
			(
				SystemTypeID	INT PRIMARY KEY
			)

		IF @TYPE IS NULL
			INSERT INTO #type(SystemTypeID)
				SELECT SystemTypeID
				FROM dbo.SystemTypeTable
		ELSE
			INSERT INTO #type(SystemTypeID)
				SELECT ID
				FROM dbo.TableIDFromXML(@TYPE)

		CREATE TABLE #net
			(
				DistrTypeID	INT PRIMARY KEY
			)

		IF @NET IS NULL
			INSERT INTO #net(DistrTypeID)
				SELECT DistrTypeID
				FROM dbo.DistrTypeTable
		ELSE
			INSERT INTO #net(DistrTypeID)
				SELECT ID
				FROM dbo.TableIDFromXML(@NET)

		CREATE TABLE #status
			(
				DS_ID	UNIQUEIDENTIFIER PRIMARY KEY
			)

		IF @STATUS IS NULL
			INSERT INTO #status(DS_ID)
				SELECT DS_ID
				FROM dbo.DistrStatus
		ELSE
			INSERT INTO #status(DS_ID)
				SELECT ID
				FROM 
					dbo.TableGUIDFromXML(@STATUS)
				

		CREATE TABLE #service
			(
				ServiceID	INT PRIMARY KEY,
				ServiceName	VARCHAR(50)
			)

		IF @SERVICE IS NULL
			INSERT INTO #service(ServiceID, ServiceName)
				SELECT ServiceID, ServiceName
				FROM dbo.ServiceTable
		ELSE
			INSERT INTO #service(ServiceID, ServiceName)
				SELECT ServiceID, ServiceName
				FROM 
					dbo.ServiceTable
					INNER JOIN dbo.TableIDFromXML(@SERVICE) ON ServiceID = ID
					
		CREATE TABLE #manager
			(
				ManagerID	INT PRIMARY KEY,
				ManagerName	VARCHAR(50)
			)

		IF @MANAGER IS NULL
			INSERT INTO #manager(ManagerID, ManagerName)
				SELECT ManagerID, ManagerName
				FROM dbo.ManagerTable
		ELSE
			INSERT INTO #manager(ManagerID, ManagerName)
				SELECT ManagerID, ManagerName
				FROM 
					dbo.ManagerTable
					INNER JOIN dbo.TableIDFromXML(@MANAGER) ON ManagerID = ID

		SELECT 
			DISTR AS SystemDistrNumber, COMP AS CompNumber, SystemTypeName, DistrTypeName, 
			SystemShortName, ClientFullName, DS_NAME AS ServiceStatusName, b.ServiceName,
			b.ManagerName, SystemOrder, b.ClientID
		FROM 
			dbo.ClientReadList()
			INNER JOIN dbo.ClientDistrView a WITH(NOEXPAND) ON ID_CLIENT = RCL_ID
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID 
			INNER JOIN #type c ON c.SystemTypeID = a.SystemTypeID 
			INNER JOIN #net d ON d.DistrTypeID = a.DistrTypeID 
			INNER JOIN #status e ON e.DS_ID = a.DS_ID
			INNER JOIN #system f ON f.SystemID = a.SystemID 
			INNER JOIN #service g ON g.ServiceID = b.ServiceID	
			INNER JOIN #manager h ON h.ManagerID = b.ManagerID		
			
		UNION 
			
		SELECT 
			DISTR AS SystemDistrNumber, COMP AS CompNumber, SystemTypeName, DistrTypeName, 
			SystemShortName, ClientFullName, DS_NAME AS ServiceStatusName, b.ServiceName,
			b.ManagerName, SystemOrder, b.ClientID
		FROM 
			dbo.ClientDistrView a WITH(NOEXPAND)
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID 
			INNER JOIN #type c ON c.SystemTypeID = a.SystemTypeID 
			INNER JOIN #net d ON d.DistrTypeID = a.DistrTypeID 
			INNER JOIN #status e ON e.DS_ID = a.DS_ID
			INNER JOIN #system f ON f.SystemID = a.SystemID 
			INNER JOIN #service g ON g.ServiceID = b.ServiceID	
			INNER JOIN #manager h ON h.ManagerID = b.ManagerID
		WHERE ORIGINAL_LOGIN() = 'Евдокимова' AND SystemBaseName IN ('RLAW020', 'RBAS020') AND DS_REG = 1 AND GETDATE() < '20150401'
			
		ORDER BY SystemOrder, DISTR, COMP, ClientFullName

		SELECT @CNT = @@ROWCOUNT
		
		IF OBJECT_ID('tempdb..#system') IS NOT NULL
			DROP TABLE #system
		IF OBJECT_ID('tempdb..#type') IS NOT NULL
			DROP TABLE #type
		IF OBJECT_ID('tempdb..#net') IS NOT NULL
			DROP TABLE #net
		IF OBJECT_ID('tempdb..#status') IS NOT NULL
			DROP TABLE #status
		IF OBJECT_ID('tempdb..#service') IS NOT NULL
			DROP TABLE #service
		IF OBJECT_ID('tempdb..#manager') IS NOT NULL
			DROP TABLE #manager
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END