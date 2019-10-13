USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[EXPERT_CLIENT_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#vmi') IS NOT NULL
		DROP TABLE #vmi

	CREATE TABLE #vmi
		(
			MON		SMALLDATETIME,
			HOST	INT,
			DISTR	INT,
			COMP	TINYINT
		)

	INSERT INTO #vmi(MON, HOST, DISTR, COMP)
		SELECT 
			MON, HostID, 
			CONVERT(INT, 
						CASE 
							WHEN CHARINDEX('_', REVERSE(DIS_S)) > 3 THEN 
									RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('_', DIS_S))
							ELSE LEFT(RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('_', DIS_S)), CHARINDEX('_', RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('_', DIS_S))) - 1)
						END) AS DISTR,
			CASE 
				WHEN CHARINDEX('_', REVERSE(DIS_S)) > 3 THEN 1
				ELSE CONVERT(INT, REVERSE(LEFT(REVERSE(DIS_S), CHARINDEX('_', REVERSE(DIS_S)) - 1)))
			END AS COMP
		FROM
			(
				SELECT DISTINCT MON, Item AS DIS_S
				FROM 
					dbo.ExpertVMI
					CROSS APPLY (SELECT Item FROM dbo.GET_STRING_TABLE_FROM_LIST(DISTR, ',')) AS o_O
			) AS a
			INNER JOIN dbo.SystemTable ON CONVERT(INT, LEFT(DIS_S, CHARINDEX('_', DIS_S) - 1)) = SystemNumber
			
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result

	CREATE TABLE #result
		(
			TP				TINYINT,
			ManagerName		VARCHAR(150), 
			ServiceName		VARCHAR(150),
			ClientFullName	VARCHAR(500),
			ClientID		INT,
			DistrStr		NVARCHAR(64),
			NT_SHORT		NVARCHAR(64),
			ExpertEnable	BIT,
			ExpertDate		SMALLDATETIME,
		)

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 'ALTER TABLE #result ADD '

	SELECT @SQL = @SQL + '[' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, MON)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, MON)) + '] BIT,'
	FROM
		(
			SELECT DISTINCT MON 
			FROM #vmi
		) AS a
	ORDER BY MON

	SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

	EXEC (@SQL)

	INSERT INTO #result(TP, ManagerName, ServiceName, ClientFullName, ClientID, DistrStr, NT_SHORT, ExpertEnable, ExpertDate)
		SELECT 
			1, ManagerName, ServiceName, ClientFullName, ClientID,
			(
				SELECT TOP 1 DistrStr
				FROM dbo.ClientDistrView b WITH(NOEXPAND)						
				WHERE b.ID_CLIENT = ClientID AND DS_REG = 0
				ORDER BY SystemOrder, DISTR, COMP
			),
			(
				SELECT TOP 1 DistrTypeName
				FROM dbo.ClientDistrView b WITH(NOEXPAND)						
				WHERE b.ID_CLIENT = ClientID AND DS_REG = 0
				ORDER BY SystemOrder, DISTR, COMP
			),
			CASE WHEN EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientDistrView b WITH(NOEXPAND)
						INNER JOIN dbo.ExpDistr c ON ID_HOST = HostID AND b.DISTR = c.DISTR AND b.COMP = c.COMP
					WHERE b.ID_CLIENT = ClientID AND c.STATUS = 1
				) THEN 1
				ELSE 0
			END,
			(
				SELECT MAX(dbo.DateOf(SET_DATE))
				FROM 
					dbo.ClientDistrView b WITH(NOEXPAND)
					INNER JOIN dbo.ExpDistr c ON ID_HOST = HostID AND b.DISTR = c.DISTR AND b.COMP = c.COMP
				WHERE b.ID_CLIENT = ClientID AND c.STATUS = 1
			)
		FROM dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
		
		UNION ALL
		
		SELECT 
			2, SubhostName, SubhostName, Comment, a.ID, DistrStr, NT_SHORT,
			CASE WHEN EXISTS
				(
					SELECT *
					FROM dbo.ExpDistr c
					WHERE ID_HOST = HostID 
						AND a.DistrNumber = c.DISTR 
						AND a.CompNumber = c.COMP 
						AND c.STATUS = 1					
				) THEN 1
				ELSE 0
			END,
			(
				SELECT MAX(dbo.DateOf(SET_DATE))
				FROM dbo.ExpDistr c 
				WHERE ID_HOST = HostID 
						AND a.DistrNumber = c.DISTR 
						AND a.CompNumber = c.COMP 
						AND c.STATUS = 1	
			)
		FROM 
			Reg.RegNodeSearchView a WITH(NOEXPAND)
			INNER JOIN 
				(
					SELECT DISTINCT MainHostID, MainCompNumber, MainDistrNumber
					FROM dbo.RegNodeMainSystemView WITH(NOEXPAND)
				) AS b ON a.HostID = b.MainHostID
					AND a.DistrNumber = b.MainDistrNumber
					AND a.CompNumber = b.MainCompNumber
		WHERE DS_REG = 0
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.HostID = a.HostID
						AND z.DISTR = a.DistrNumber
						AND z.COMP = a.CompNumber
				)

	SET @SQL = ''
	SELECT @SQL = @SQL + '
	UPDATE #result
	SET [' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, MON)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, MON)) + '] = 
		CASE TP 
			WHEN 1 THEN
				(
					SELECT COUNT(*) 
					FROM 
						#vmi a 
						INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HOST = b.HostID 
																	AND a.DISTR = b.DISTR 
																	AND a.COMP = b.COMP 
					WHERE ClientID = ID_CLIENT AND DATEPART(YEAR, MON) = ''' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + ''' AND DATEPART(MONTH, MON) = ''' + CONVERT(VARCHAR(4), DATEPART(MONTH, MON)) + '''
				)
			WHEN 2 THEN
				(
					SELECT COUNT(*) 
					FROM 
						#vmi a 
						INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HOST = b.HostID 
																	AND a.DISTR = b.DistrNumber
																	AND a.COMP = b.CompNumber
					WHERE ClientID = ID AND DATEPART(YEAR, MON) = ''' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + ''' AND DATEPART(MONTH, MON) = ''' + CONVERT(VARCHAR(4), DATEPART(MONTH, MON)) + '''
				)
		END
	'
	FROM 
		(
			SELECT DISTINCT MON 
			FROM #vmi
		) AS a
		
	EXEC (@SQL)

	SET @SQL = 'SELECT ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент], DistrStr AS [Дистрибутив], NT_SHORT AS [Сеть], ExpertEnable AS [Кнопка включена], ExpertDate AS [Дата подключения],'
	SELECT @SQL = @SQL + '[' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, MON)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, MON)) + '],'
	FROM
		(
			SELECT DISTINCT MON 
			FROM #vmi
		) AS a
	ORDER BY MON

	SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + ' FROM #result ORDER BY TP DESC, ManagerName, ServiceName, ClientFullName'

	EXEC (@SQL)

	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
			
	IF OBJECT_ID('tempdb..#vmi') IS NOT NULL
		DROP TABLE #vmi
END
