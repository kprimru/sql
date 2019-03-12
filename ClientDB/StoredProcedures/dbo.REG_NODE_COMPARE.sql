USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[REG_NODE_COMPARE]
	@SERVICE INT, 
	@MANAGER INT, 
	@REG BIT, 
	@BASE BIT, 
	@REG_ACTIVE BIT, 
	@NET BIT, 
	@STATUS BIT, 
	@SUBHOST_NAME VARCHAR(20),
	@SUBHOST BIT
AS
BEGIN
	SET NOCOUNT ON;

	/* @SUBHOST_NOT - заменим на SUBHOST и будем проверять соответствие подхостов	*/

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	CREATE TABLE #temp
		(
			ClientID INT,
			ClientFullName VARCHAR(250),
			ManagerName	VARCHAR(100),
			ServiceName VARCHAR(100),
			DisStr VARCHAR(100),
			ErType VARCHAR(50),
			BaseValue VARCHAR(150),
			RegValue VARCHAR(150),
			RegComment VARCHAR(100),
			RegisterDate SMALLDATETIME
		)
	
	IF @REG = 1
		INSERT INTO #temp (ClientID, ClientFullName, ManagerName, ServiceName, DisStr, ErType, BaseValue, RegValue, RegComment, RegisterDate)
			SELECT 
				a.ClientID, ClientFullName, ManagerName, ServiceName, dbo.DistrString(SystemShortName, DISTR, COMP), 
				'Система не найдена в РЦ', '', '', '', NULL
			FROM 
				dbo.ClientView a WITH(NOEXPAND) INNER JOIN
				dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT 
			WHERE b.SystemReg = 1 AND b.DS_REG = 0
				AND NOT EXISTS
				(
					SELECT *
					FROM dbo.RegNodeView d WITH(NOEXPAND)
					WHERE d.SystemName = b.SystemBaseName
						AND d.DistrNumber = b.DISTR
						AND d.CompNumber = b.COMP
						AND (d.SubhostName = @SUBHOST_NAME OR @SUBHOST_NAME IS NULL)				
				) 
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)

		
	IF @BASE = 1
		INSERT INTO #temp (ClientID, ClientFullName, ManagerName, ServiceName, DisStr, ErType, BaseValue, RegValue, RegComment, RegisterDate)
			SELECT 
				(
					SELECT TOP 1 ID_CLIENT
					FROM 
						dbo.ClientView z WITH(NOEXPAND)
						INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.ClientID = y.ID_CLIENT
						INNER JOIN dbo.RegNodeTable x ON x.SystemName = y.SystemBaseName AND x.DistrNumber = y.DISTR AND x.CompNumber = y.COMP
					WHERE x.Complect = d.Complect
					ORDER BY x.Service, y.SystemOrder
				), '', 
				(
					SELECT TOP 1 ManagerName
					FROM 
						dbo.ClientView z WITH(NOEXPAND)
						INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.ClientID = y.ID_CLIENT
						INNER JOIN dbo.RegNodeTable x ON x.SystemName = y.SystemBaseName AND x.DistrNumber = y.DISTR AND x.CompNumber = y.COMP
					WHERE x.Complect = d.Complect
					ORDER BY x.Service, y.SystemOrder
				), 
				(
					SELECT TOP 1 ServiceName
					FROM 
						dbo.ClientView z WITH(NOEXPAND)
						INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.ClientID = y.ID_CLIENT
						INNER JOIN dbo.RegNodeTable x ON x.SystemName = y.SystemBaseName AND x.DistrNumber = y.DISTR AND x.CompNumber = y.COMP
					WHERE x.Complect = d.Complect
					ORDER BY x.Service, y.SystemOrder
				), 
				dbo.DistrString(ISNULL(SystemShortName, d.SystemName), DistrNumber, CompNumber), 
				'Система не найдена в базе', '', '', Comment, RegisterDate
			FROM 
				dbo.RegNodeView d WITH(NOEXPAND) LEFT OUTER JOIN
				dbo.SystemTable e ON e.SystemBaseName = d.SystemName
			WHERE DistrNumber <> 20 AND DistrType NOT IN ('NEK', 'DSP')
				AND NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ClientTable a INNER JOIN
						dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
					WHERE 
						d.SystemName = b.SystemBaseName
						AND d.DistrNumber = b.DISTR
						AND d.CompNumber = b.COMP
						AND STATUS = 1
				) AND Subhost = 0 AND (Service = 0 OR @REG_ACTIVE = 0) 
				AND 
					SubhostName = 
					CASE 
						WHEN @SUBHOST = 1 THEN ''						
						ELSE SubhostName 
					END
				AND (d.SubhostName = @SUBHOST_NAME OR @SUBHOST_NAME IS NULL)

	IF @NET = 1 
		INSERT INTO #temp (ClientID, ClientFullName, ManagerName, ServiceName, DisStr, ErType, BaseValue, RegValue, RegComment, RegisterDate)
			SELECT ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, ErType, BaseValue, RegValue, Comment, RegisterDate
			FROM
				(
					SELECT 
						a.ClientID, ClientFullName, ManagerName, ServiceName, b.DistrStr, 'Несоответствие типа сети' AS ErType, 
						b.DistrTypeName AS BaseValue, 
						g.DistrTypeName AS RegValue,
						Comment, RegisterDate
					FROM 
						dbo.ClientView a WITH(NOEXPAND) INNER JOIN
						dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT INNER JOIN
						Reg.RegNodeSearchView d WITH(NOEXPAND) ON d.SystemID = b.SystemID
									AND d.DistrNumber = b.DISTR
									AND d.CompNumber = b.COMP INNER JOIN				
						Din.NetType e ON e.NT_ID = d.NT_ID INNER JOIN
						dbo.DistrTypeTable g ON g.DistrTypeID = e.NT_ID_MASTER INNER JOIN
						dbo.SystemTypeTable f ON f.SystemTypeID = b.SystemTypeID
					WHERE 
							(ServiceID = @SERVICE OR @SERVICE IS NULL)
							AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
							AND (d.SubhostName = @SUBHOST_NAME OR @SUBHOST_NAME IS NULL)
				) AS o_O
			WHERE RegValue <> BaseValue

	IF @STATUS = 1 
		INSERT INTO #temp (ClientID, ClientFullName, ManagerName, ServiceName, DisStr, ErType, BaseValue, RegValue, RegComment, RegisterDate)
			SELECT ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, ErType, BaseValue, RegValue, Comment, RegisterDate
			FROM
				(
					SELECT 
						a.ClientID, ClientFullName, ManagerName, ServiceName, 
						dbo.DistrString(SystemShortName, DISTR, b.COMP) AS DistrStr, 
						'Несоответствие статуса' AS ErType, 
						b.DS_NAME AS BaseValue, 
						d.DS_NAME AS RegValue,
						Comment, RegisterDate
					FROM 
						dbo.ClientView a WITH(NOEXPAND) INNER JOIN
						dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT INNER JOIN	
						dbo.RegNodeView d WITH(NOEXPAND) ON d.SystemName = b.SystemBaseName
									AND d.DistrNumber = b.DISTR
									AND d.CompNumber = b.COMP
					WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
						AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
						AND (d.SubhostName = @SUBHOST_NAME OR @SUBHOST_NAME IS NULL)
				) AS o_O
			WHERE RegValue <> BaseValue				
	
	SELECT 
		ClientID, ClientFullName, ManagerName, ServiceName, DisStr, ErType, BaseValue, RegValue, RegComment, RegisterDate
	FROM #temp
	ORDER BY ErType, ClientFullName, RegComment, DisStr
END