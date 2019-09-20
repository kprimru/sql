USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DUTY_SYSTEM_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT,
	@CNT		INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @END IS NOT NULL
		SET @END = DATEADD(DAY, 1, @END)

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client
		(
			ClientID		INT /*PRIMARY KEY*/,
			ClientFullName	VARCHAR(250),
			ServiceName		VARCHAR(150),
			ManagerName		VARCHAR(150)
		)

	INSERT INTO #client(ClientID, ClientFullName, ServiceName, ManagerName)
		SELECT 
			ClientID, ClientFullName, ServiceName, ManagerName
		FROM dbo.ClientView a WITH(NOEXPAND)		
		WHERE ServiceStatusID = 2
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			
	IF OBJECT_ID('tempdb..#duty') IS NOT NULL
		DROP TABLE #duty
		
	CREATE TABLE #duty
		(
			TP				VARCHAR(10),
			ClientID		INT,
			ClientFullName	VARCHAR(255),
			ServiceName		VARCHAR(150),
			ManagerName		VARCHAR(150),
			SystemShortName	VARCHAR(50),
			SystemOrder		INT,
			SYS_CNT			INT,
			SYS_EXISTS		VARCHAR(50),
			VERDIKT			VARCHAR(50)
		)
			
	INSERT INTO #duty(TP, ClientID, ClientFullName, ServiceName, ManagerName, 
		SystemShortName, SYS_CNT, SYS_EXISTS, VERDIKT)
		SELECT 	
			TP, ClientID, ClientFullName, ServiceName, ManagerName, 
			SystemShortName, SYS_CNT, SYS_EXISTS, VERDIKT
		FROM
			(
				SELECT 
					TP, ClientID, ClientFullName, ServiceName, ManagerName, 
					SystemShortName, SYS_CNT, SystemOrder,
					CASE
						WHEN p.DS_REG = 0 THEN 'Есть'
						WHEN p.DS_REG <> 0 THEN 'Отключена'
						WHEN p.DS_REG IS NULL THEN 'Нет'
						ELSE ''
					END AS SYS_EXISTS,
					CASE
						WHEN p.DS_REG = 0 THEN
							CASE
								WHEN TP = 'INET' THEN 'Повышение'
								ELSE 'Обучение'
							END
						WHEN p.DS_REG <> 0 THEN 'Восстановление'
						WHEN p.DS_REG IS NULL THEN 'Допродажа'
						ELSE ''
					END AS VERDIKT
				FROM
					(
						SELECT 
							'DUTY' AS TP,
							a.ClientID, ClientFullName, ServiceName, ManagerName, 
							d.SystemID, d.SystemShortName, d.SystemOrder, COUNT(*) AS SYS_CNT
						FROM 
							#client a
							INNER JOIN dbo.ClientDutyTable b ON a.ClientID = b.ClientID
							INNER JOIN dbo.ClientDutyIBTable c ON c.ClientDutyID = b.ClientDutyID
							INNER JOIN dbo.SystemTable d ON d.SystemID = c.SystemID
						WHERE (ClientDutyDateTime >= @BEGIN OR @BEGIN IS NULL)
							AND (ClientDutyDateTime < @END OR @END IS NULL)
							AND b.STATUS = 1
						GROUP BY a.ClientID, ClientFullName, ServiceName, ManagerName, 
							d.SystemShortName, d.SystemOrder, d.SystemID
							
						UNION ALL
						
						SELECT 
							'STUDY' AS TP,
							a.ClientID, ClientFullName, ServiceName, ManagerName, 
							d.SystemID, d.SystemShortName, d.SystemOrder, COUNT(*) AS SYS_CNT
						FROM 
							#client a
							INNER JOIN dbo.ClientStudy b ON a.ClientID = b.ID_CLIENT
							INNER JOIN dbo.ClientStudySystem c ON c.ID_STUDY = b.ID
							INNER JOIN dbo.SystemTable d ON d.SystemID = c.ID_SYSTEM
						WHERE (b.DATE >= @BEGIN OR @BEGIN IS NULL)
							AND (b.DATE < @END OR @END IS NULL)
							AND b.STATUS = 1
							AND b.Teached = 1
						GROUP BY a.ClientID, ClientFullName, ServiceName, ManagerName, 
							d.SystemShortName, d.SystemOrder, d.SystemID
							
						UNION ALL
						
						SELECT 
							'INET' AS TP,
							a.ClientID, ClientFullName, ServiceName, ManagerName, 
							t.SystemID, t.SystemShortName, t.SystemOrder, COUNT(*) AS SYS_CNT
						FROM 
							#client a
							INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
							INNER JOIN dbo.SystemTable c ON b.SystemID = c.SystemID
							INNER JOIN dbo.ControlDocument d ON d.SYS_NUM = c.SystemNumber AND d.DISTR = b.DISTR AND d.COMP = b.COMP
							CROSS APPLY
							(
								SELECT TOP 1 q.SystemID, q.SystemShortName, q.SystemOrder
								FROM dbo.SystemTable q
								--ToDo убрать злостный хардкод
								CROSS APPLY dbo.SystemBankGet(q.SystemID, 2) z
								WHERE z.InfoBankName = d.IB
									AND z.SystemBaseName NOT IN ('BVP', 'JURP', 'BUDP', 'JUR', 'MBP')
								ORDER BY q.SystemOrder
							) t
						WHERE (DATE >= @BEGIN OR @BEGIN IS NULL)
							AND (DATE < @END OR @END IS NULL)
						GROUP BY a.ClientID, ClientFullName, ServiceName, ManagerName, 
							t.SystemShortName, t.SystemOrder, t.SystemID
					) AS o_O 
					OUTER APPLY
					(
						SELECT TOP 1 DS_REG
						FROM
							dbo.ClientDistrView t WITH(NOEXPAND)
							LEFT OUTER JOIN dbo.SystemSlaveView q ON q.ID_MASTER = t.SystemID
						WHERE ID_CLIENT = ClientID
							AND (o_O.SystemID = t.SystemID OR o_O.SystemID = q.ID_SLAVE)
						ORDER BY DS_REG
					) AS p
				WHERE (SYS_CNT >= @CNT OR @CNT IS NULL)
			) AS o_O
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder

	SELECT 
		ROW_NUMBER() OVER(PARTITION BY ClientID ORDER BY SystemOrder) AS RN,		
		ClientID, ClientFullName, ServiceName, ManagerName, 
		CASE TP
			WHEN 'INET' THEN 'Скачан'
			WHEN 'DUTY' THEN 'ДС'
			WHEN 'STUDY' THEN 'Обучение'
			ELSE ''
		END AS TP_STR,
		SystemShortName, SYS_CNT, SYS_EXISTS, VERDIKT
	FROM #duty
	ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder

	IF OBJECT_ID('tempdb..#duty') IS NOT NULL
		DROP TABLE #duty
					
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END
