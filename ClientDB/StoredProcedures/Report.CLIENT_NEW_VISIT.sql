USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CLIENT_NEW_VISIT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr

	CREATE TABLE #distr
		(
			DATE	SMALLDATETIME,
			ID_HOST	SMALLINT,
			DISTR	INT,
			COMP	TINYINT
		)

		INSERT INTO #distr(ID_HOST, DISTR, COMP, DATE)
			SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
			FROM 
				dbo.RegProtocol
				INNER JOIN dbo.Hosts ON RPR_ID_HOST = HostID
			WHERE RPR_OPER IN ('Новая')
				AND HostReg = 'LAW'
	DELETE
	FROM #distr
	WHERE EXISTS
		(
			SELECT *
			FROM 
				dbo.RegNodeTable a
				INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
				INNER JOIN Din.SystemType c ON c.SST_REG = a.DistrType
			WHERE DistrNumber = DISTR AND CompNumber = COMP AND HostID = ID_HOST AND SST_WEIGHT = 0
		)
		 
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result	
		 
	SELECT	
		DATE,
		ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,
		dbo.DistrWeight(SystemID, DistrTypeID, SystemTypeName, DATE) AS WEIGHT
	INTO #result
	FROM 
		#distr a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP AND a.ID_HOST = b.HostID
		INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT		
	ORDER BY DATE DESC, ManagerName, ServiceName, SystemOrder

	SELECT 
		ManagerName AS [Руководитель], ServiceName AS [СИ], ClientFullName AS [Клиент], DistrStr AS [Дистрибутив], DistrTypeName AS [Сеть],
		DATE AS [Дата подключения], WEIGHT AS [Вес],
		CONVERT(BIT, CASE WHEN NOT EXISTS
			(
				SELECT ID
				FROM dbo.ClientContact z
				WHERE ID_CLIENT = ClientID
					AND STATUS = 1
					AND z.DATE >= a.DATE
					
				UNION ALL
				
				SELECT ID
				FROM Task.Tasks z
				WHERE ID_CLIENT = ClientID
					AND STATUS = 1
					AND z.DATE >= a.DATE
			) THEN 0 ELSE 1 END) AS [Наличие записи о визите],
		REVERSE(STUFF(REVERSE((
			SELECT CONVERT(NVARCHAR(32), DATE, 104) + CHAR(10) + PERSONAL + CHAR(10) + NOTE + CHAR(10) + CHAR(10) + PROBLEM + CHAR(10)+CHAR(10)+CHAR(10)
			FROM
				(
					SELECT DATE, PERSONAL, NOTE, PROBLEM
					FROM  
						dbo.ClientContact z
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND z.DATE >= a.DATE
						
					UNION ALL
					
					SELECT DATE, SENDER, NOTE, ''
					FROM Task.Tasks z
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND z.DATE >= a.DATE
				) AS z
			ORDER BY z.DATE DESC FOR XML PATH('')
		)), 1, 3, '')) AS [Запись о визите]
		/*
		CONVERT(BIT, CASE WHEN NOT EXISTS
			(
				SELECT *
				FROM Task.Tasks z
				WHERE ID_CLIENT = ClientID
					AND STATUS = 1
					AND z.DATE >= a.DATE
			) THEN 0 ELSE 1 END) AS [Наличие записи о визите],
		REVERSE(STUFF(REVERSE((
			SELECT CONVERT(NVARCHAR(32), DATE, 104) + CHAR(10) + SENDER + CHAR(10) + SHORT + CHAR(10) + NOTE + CHAR(10)+CHAR(10)+CHAR(10)
			FROM Task.Tasks z
			WHERE ID_CLIENT = ClientID
				AND STATUS = 1
				AND z.DATE >= a.DATE
			ORDER BY z.DATE DESC FOR XML PATH('')
		)), 1, 3, '')) AS [Запись о визите]
		*/
	FROM #result a
	WHERE DATE >= DATEADD(YEAR, -1, GETDATE())
	ORDER BY DATE DESC, ManagerName, ServiceName
	
		 
	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
		
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result

END
