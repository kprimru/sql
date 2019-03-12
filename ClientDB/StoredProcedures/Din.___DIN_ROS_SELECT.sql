USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Din].[DIN_ROS_SELECT]
	@PROBLEM	BIT,
	@MANAGER	INT,
	@SERVICE	INT,
	@CLIENT		VARCHAR(50),
	@SST_LIST	VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	CREATE TABLE #distr
		(	
			ClientID INT,
			Problem BIT,
			DistrStr VARCHAR(50),
			SST_SHORT VARCHAR(100),
			ClientFullName VARCHAR(500),
			ManagerName VARCHAR(100),
			ServiceName VARCHAR(100),
			ServicedSys VARCHAR(MAX),
			UnservicesSys VARCHAR(MAX),
			SystemID	INT,
			DistrNumber INT,
			CompNumber TINYINT
		)
	
	INSERT INTO #distr(ClientID, Problem, DistrStr, SST_SHORT, ClientFullName, ManagerName, ServiceName, ServicedSys, UnservicesSys, SystemID, DistrNumber, CompNumber)
		SELECT		
			e.ClientID, Problem, b.SystemShortName + ' ' + CONVERT(VARCHAR(20), DistrNumber) + 
			CASE a.CompNumber 
				WHEN 1 THEN '' 
				ELSE '/' + CONVERT(VARCHAR(20), a.CompNumber) 
			END AS DistrStr, SST_SHORT, 
			ISNULL(ClientFullName, Comment) AS ClientFullName,
			ManagerName, ServiceName,
			ISNULL(REVERSE(STUFF(REVERSE((
				SELECT SystemShortName + ' ' + CONVERT(VARCHAR(20), DistrNumber) +
					CASE CompNumber 
						WHEN 1 THEN '' 
						ELSE '/' + CONVERT(VARCHAR(20), CompNumber) 
					END + ', '
				FROM 
					dbo.RegNodeTable z
					INNER JOIN dbo.SystemTable y ON z.SystemName = y.SystemBaseName
				WHERE z.Service = 0 AND z.Complect = a.Complect AND  a.SystemName <> z.SystemName
				ORDER BY SystemOrder, DistrNumber FOR XML PATH('')
			)), 1, 2, '')), '') AS ServicedSys,
			ISNULL(REVERSE(STUFF(REVERSE((
				SELECT SystemShortName + ' ' + CONVERT(VARCHAR(20), DistrNumber) +
					CASE CompNumber 
						WHEN 1 THEN '' 
						ELSE '/' + CONVERT(VARCHAR(20), CompNumber) 
					END + ', '
				FROM 
					dbo.RegNodeTable z
					INNER JOIN dbo.SystemTable y ON z.SystemName = y.SystemBaseName
				WHERE z.Service = 1 AND z.Complect = a.Complect AND  a.SystemName <> z.SystemName
				ORDER BY SystemOrder, DistrNumber FOR XML PATH('')
			)), 1, 2, '')), '') AS UnservicesSys,
			b.SystemID, a.DistrNumber, a.CompNumber
		FROM 
			dbo.RegNodeProblemView a
			INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName			
			INNER JOIN Din.SystemType c ON SST_REG = DistrType
			INNER JOIN dbo.GET_TABLE_FROM_LIST(@SST_LIST, ',') ON Item = SST_ID
			LEFT OUTER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON d.SystemID = b.SystemID 
													AND d.DISTR = a.DistrNumber 
													AND d.COMP = a.CompNumber
			LEFT OUTER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = d.ID_CLIENT
		WHERE Service = 0 AND b.SystemBaseName = 'ROS'
			AND (e.ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (e.ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (e.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL OR Comment LIKE @CLIENT)
			AND (@PROBLEM = 0 OR @PROBLEM IS NULL OR @PROBLEM = 1 AND Problem = 1)
	
	SELECT 
		ClientID, Problem, DistrStr, SST_SHORT, ClientFullName, ManagerName, ServiceName, ServicedSys, UnservicesSys, 
		(
			SELECT MAX(UF_DATE)
			FROM 
				USR.USRActiveView z
				INNER JOIN USR.USRPackage x ON z.UF_ID = x.UP_ID_USR				
			WHERE a.SystemID = UP_ID_SYSTEM AND x.UP_DISTR = a.DistrNumber AND x.UP_COMP = a.CompNumber
		) AS LAST_UPDATE
	FROM #distr AS a
	ORDER BY ManagerName, ServiceName, ClientFullName
	
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
END