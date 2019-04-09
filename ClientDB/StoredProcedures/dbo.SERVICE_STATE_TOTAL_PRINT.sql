USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATE_TOTAL_PRINT]
	@MANAGER	NVARCHAR(MAX),
	@TP			NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;	
	
	IF ISNULL(@TP, '') = ''
	BEGIN
		SET @TP = ''
		SELECT @TP = @TP + ',' + TP
		FROM 
			(
				SELECT DISTINCT TP
				FROM dbo.ServiceStateDetail
			) AS o_O
		WHERE TP <> 'PAY'
		
		SET @TP = LEFT(@TP, LEN(@TP) - 1)
	END
		
		
	SELECT DISTINCT a.ServiceName, a.ManagerName, f.ClientFullName AS TP_NOTE, DETAIL AS NOTE, DATE AS DT, TP_NAME, TP_ORD, TP_NOTE AS GRP_NAME,
		(
			SELECT COUNT(*)
			FROM dbo.ServiceStateDetail z
			WHERE z.ID_STATE = b.ID
				AND z.TP = d.TP_NAME
		) AS GRP_CNT
	FROM
		(
			SELECT b.ServiceID, b.ServiceName, ManagerName
			FROM 
				dbo.TableIDFromXML(@MANAGER) a
				INNER JOIN dbo.ServiceTable b ON a.ID = b.ManagerID
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ServiceID = b.ServiceID
			WHERE c.ServiceStatusID = 2
		) AS a
		INNER JOIN dbo.ServiceState b ON b.ID_SERVICE = a.ServiceID AND b.STATUS = 1	
		INNER JOIN dbo.ServiceStateDetail c ON b.ID = c.ID_STATE
		INNER JOIN dbo.ServiceStateTypeView d ON c.TP = d.TP_NAME
		INNER JOIN dbo.GET_STRING_TABLE_FROM_LIST(@TP, ',') e ON e.Item = d.TP_NAME
		INNER JOIN dbo.ClientTable f ON f.ClientID = c.ID_CLIENT
	ORDER BY ManagerName, ServiceName, TP_ORD, TP_NAME
		
	/*
	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res
		
	CREATE TABLE #res
		(
			ID_SERVICE	INT,
			TP_NOTE		NVARCHAR(512),
			NOTE		NVARCHAR(MAX),
			DT			DATETIME,
			TP_NAME		NVARCHAR(32),
			TP_ORD		INT,
			GRP_NAME	NVARCHAR(512), 
			GRP_CNT		NVARCHAR(512)
		)

	DECLARE @DT DATETIME
	DECLARE @SERVICE INT

	DECLARE SRV CURSOR LOCAL FOR
		SELECT b.ServiceID
		FROM 
			dbo.TableIDFromXML(@MANAGER) a
			INNER JOIN dbo.ServiceTable b ON a.ID = b.ManagerID
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ServiceID = b.ServiceID
		WHERE c.ServiceStatusID = 2

	OPEN SRV
				
	FETCH NEXT FROM SRV INTO @SERVICE
				
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF OBJECT_ID('tempdb..#r') IS NOT NULL
			DROP TABLE #r
			
		CREATE TABLE #r
			(
				ID			UNIQUEIDENTIFIER,
				ID_MASTER	UNIQUEIDENTIFIER,
				TP_NOTE		NVARCHAR(512),
				NOTE		NVARCHAR(MAX),
				TP_NAME		NVARCHAR(32),
				TP_ORD		INT
			)
				
		INSERT INTO #r
			EXEC [dbo].[SERVICE_STATE_SELECT] @SERVICE, @DT OUTPUT
		
		DELETE
		FROM #r
		WHERE TP_NAME NOT IN
			(
				SELECT ITEM
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@TP, ',')
			)
		
		DELETE a FROM #r a WHERE ID_MASTER IS NOT NULL AND NOT EXISTS (SELECT * FROM #r b WHERE a.ID_MASTER = b.ID)
			
		ALTER TABLE #r ADD GRP_NAME NVARCHAR(512), GRP_CNT	NVARCHAR(512)
			
		UPDATE a
		SET a.TP_NAME = b.TP_NAME,
			a.TP_ORD = b.TP_ORD,
			GRP_NAME = b.TP_NOTE,
			GRP_CNT = b.NOTE
		FROM 
			#r a
			INNER JOIN #r b ON a.ID_MASTER = b.ID
		WHERE a.TP_NAME IS NULL
			
		DELETE FROM #r WHERE ID_MASTER IS NULL
			
		INSERT INTO #res(ID_SERVICE, TP_NOTE, NOTE, DT, TP_NAME, GRP_NAME, GRP_CNT)
			SELECT @SERVICE, TP_NOTE, NOTE, @DT, TP_NAME, GRP_NAME, GRP_CNT
			FROM #r
			ORDER BY TP_ORD, TP_NAME
		
		FETCH NEXT FROM SRV INTO @SERVICE
		
		IF OBJECT_ID('tempdb..#r') IS NOT NULL
			DROP TABLE #r
	END
		
	SELECT b.ServiceName, c.ManagerName, TP_NOTE, NOTE, DT, TP_NAME, GRP_NAME, GRP_CNT
	FROM 
		#res a
		INNER JOIN dbo.ServiceTable b ON a.ID_SERVICE = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON b.ManagerID = c.ManagerID
	ORDER BY ManagerName, ServiceName, TP_ORD, TP_NAME	
		
	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res
		
	CLOSE SRV
	DEALLOCATE SRV
	*/
END
