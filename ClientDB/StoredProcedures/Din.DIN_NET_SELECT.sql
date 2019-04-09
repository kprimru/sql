USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[DIN_NET_SELECT]
	@MANAGER	INT,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL
		
	IF @TYPE IS NULL
	BEGIN
		SET @TYPE = ''
		
		SELECT @TYPE = @TYPE + CONVERT(VARCHAR(20), SST_ID) + ','
		FROM Din.SystemType
		
		SELECT @TYPE = LEFT(@TYPE, LEN(@TYPE) - 1)
	END
		
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
		
	CREATE TABLE #client
		(
			ClientID		INT,
			ClientFullName	VARCHAR(250),
			ManagerName		VARCHAR(150),
			ServiceName		VARCHAR(150),
			DistrStr		VARCHAR(50),
			UD_ID			UNIQUEIDENTIFIER,
			UD_NAME		VARCHAR(50),
			SST_SHORT		VARCHAR(50),
			NT_SHORT		VARCHAR(50)
		)	

	INSERT INTO #client(ClientID, ClientFullName, ManagerName, ServiceName, UD_ID, UD_NAME, DistrStr, SST_SHORT, NT_SHORT)
		SELECT 
			a.ClientID,
			ClientFullName, ManagerName, ServiceName, UD_ID, NULL AS UD_NAME, 
			dbo.DistrString(c.SystemShortName, d.DistrNumber, d.CompNumber) AS DistrStr,
			SST_SHORT, NT_SHORT
		FROM 
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
			INNER JOIN dbo.SystemTable c ON c.SystemID = b.SystemID
			INNER JOIN dbo.RegNodeTable d ON d.SystemName = b.SystemBaseName
										AND d.DistrNumber = b.DISTR
										AND d.CompNumber = b.COMP
			INNER JOIN Din.SystemType e ON SST_REG = d.DistrType
			INNER JOIN dbo.GET_TABLE_FROM_LIST(@TYPE, ',') ON SST_ID = Item
			INNER JOIN Din.NetType ON NT_TECH = TechnolType AND NT_NET = NetCount AND NT_ODON = ODON AND NT_ODOFF = ODOFF
			LEFT OUTER JOIN USR.USRData q ON q.UD_ID_HOST = b.HostID AND q.UD_DISTR = b.DISTR AND q.UD_COMP = b.COMP
		WHERE c.SystemBaseName IN ('LAW', 'ROS', 'JUR', 'MBP', 'BUHU', 'BUHUL', 'BUH', 'BUHL', 'BUD', 'BUDU')
			AND Service = 0
			AND NetCount > 1
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName
		
	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
		
	CREATE TABLE #usr
		(
			UD_ID	UNIQUEIDENTIFIER,
			UF_DATE	DATETIME,
			UF_OD	INT,
			UF_UD	INT
		)
		
	DECLARE @LAST_DATE	DATETIME

	SET @LAST_DATE = DATEADD(MONTH, -2, GETDATE())
		
	INSERT INTO #usr(UD_ID, UF_DATE, UF_OD, UF_UD)
		SELECT UF_ID_COMPLECT, UF_DATE, t.UF_OD, t.UF_UD
		FROM 
			#client
			INNER JOIN USR.USRFile f ON UF_ID_COMPLECT = UD_ID
			INNER JOIN USR.USRFIleTech t ON f.UF_ID = t.UF_ID
		WHERE UF_ACTIVE = 1 AND UF_DATE >= @LAST_DATE
		
	INSERT INTO #usr(UD_ID, UF_DATE, UF_OD, UF_UD)
		SELECT UD_ID, UF_DATE, UF_OD, UF_UD
		FROM
			#client a
			CROSS APPLY
				(
					SELECT TOP 1 UF_DATE, t.UF_OD, t.UF_UD
					FROM USR.USRFile f
					INNER JOIN USR.USRFileTech t ON f.UF_ID = t.UF_ID
					WHERE UF_ID_COMPLECT = a.UD_ID
						AND UF_ACTIVE = 1
					ORDER BY UF_DATE DESC
				) z
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #usr b
				WHERE a.UD_ID = b.UD_ID
			)
		
	SELECT 
		ClientID, ClientFullName, ManagerName, ServiceName, UD_NAME, DistrStr, SST_SHORT, NT_SHORT,
		UF_DATE, 
		CASE
			WHEN UF_DATE < @LAST_DATE THEN 1
			ELSE 0 
		END AS UF_DATE_OLD,
		UF_MAX_OD, UF_MAX_UD, UF_AVG_OD, UF_AVG_UD
	FROM
		(
			SELECT 
				ClientID, ClientFullName, ManagerName, ServiceName, UD_ID, UD_NAME, DistrStr, SST_SHORT, NT_SHORT,
				(
					SELECT MAX(UF_DATE)
					FROM #usr b
					WHERE a.UD_ID = b.UD_ID
				) AS UF_DATE,
				(
					SELECT MAX(UF_OD)
					FROM #usr b
					WHERE a.UD_ID = b.UD_ID
				) AS UF_MAX_OD,
				(
					SELECT MAX(UF_UD)
					FROM #usr b
					WHERE a.UD_ID = b.UD_ID
				) AS UF_MAX_UD,
				(
					SELECT AVG(UF_OD)
					FROM #usr b
					WHERE a.UD_ID = b.UD_ID
						AND UF_OD <> 0
				) AS UF_AVG_OD,
				(
					SELECT AVG(UF_UD)
					FROM #usr b
					WHERE a.UD_ID = b.UD_ID
						AND UF_UD <> 0
				) AS UF_AVG_UD
			FROM #client a
		) AS o_O
	ORDER BY ManagerName, ServiceName, ClientFullName
		
	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
		
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END