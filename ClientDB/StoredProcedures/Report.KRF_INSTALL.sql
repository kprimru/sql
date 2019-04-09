USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[KRF_INSTALL]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], a.DistrStr AS [Дистрибутив], 
		ISNULL(ClientFullName, Comment) AS [Клиент], NT_SHORT AS [Сеть], SST_SHORT AS [Тип дистрибутива]/*,
		(
			SELECT MAX(UIU_DATE_S)
			FROM 
				dbo.SystemBanksView z WITH(NOEXPAND)
				INNER JOIN USR.USRIBDateView y WITH(NOEXPAND) ON y.UI_ID_BASE = z.InfoBankID
			WHERE z.SystemID = a.SystemID AND y.UI_DISTR = a.DistrNumber AND y.UI_COMP = a.CompNumber
		) AS [Последнее обновление]*/
	FROM 
		Reg.RegNodeSearchView a WITH(NOEXPAND)
		LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = a.SystemID AND DISTR = DistrNumber AND COMP = CompNumber
		LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON ClientID = ID_CLIENT
	WHERE a.DS_REG = 0
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND NT_TECH IN (0, 1)
		AND Complect IS NOT NULL
		AND		
			(
					
					Complect NOT LIKE 'LAW%'
					AND Complect NOT LIKE 'BUHL%'
					AND Complect NOT LIKE 'MBP%'
					AND Complect NOT LIKE 'BVP%'
					AND Complect NOT LIKE 'BUDP%'
					AND Complect NOT LIKE 'JURP%'
					AND Complect NOT LIKE 'JUR%'
					AND Complect NOT LIKE 'BUD%'
					AND Complect NOT LIKE 'BUHUL%'
					AND Complect NOT LIKE 'BBKZ%'
					AND Complect NOT LIKE 'UMKZ%'
					AND Complect NOT LIKE 'UBKZ%'
					AND Complect NOT LIKE 'RGN%'
					AND Complect NOT LIKE 'RLAW%'
					AND Complect NOT LIKE 'NBU%'
					AND Complect NOT LIKE 'KRF%'
				)
	
	UNION ALL
	
	SELECT 
		ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], a.DistrStr AS [Дистрибутив], 
		ISNULL(ClientFullName, Comment) AS [Клиент], NT_SHORT AS [Сеть], SST_SHORT AS [Тип дистрибутива]/*,
		(
			SELECT MAX(UIU_DATE_S)
			FROM 
				dbo.SystemBanksView z WITH(NOEXPAND)
				INNER JOIN USR.USRIBDateView y WITH(NOEXPAND) ON y.UI_ID_BASE = z.InfoBankID
			WHERE z.SystemID = a.SystemID AND y.UI_DISTR = a.DistrNumber AND y.UI_COMP = a.CompNumber
		) AS [Последнее обновление]*/
	FROM 
		Reg.RegNodeSearchView a WITH(NOEXPAND)
		LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = a.SystemID AND DISTR = DistrNumber AND COMP = CompNumber
		LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON ClientID = ID_CLIENT
	WHERE a.DS_REG = 0
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND Complect IS NOT NULL
		AND a.SystemShortName = 'КРФ'
		AND	NOT EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
				WHERE a.Complect = z.Complect
					AND z.DS_REG = 0
					AND z.SystemShortName <> 'КРФ'
			)
				
	UNION ALL
	
	SELECT 
		ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], a.DistrStr AS [Дистрибутив], 
		ISNULL(ClientFullName, Comment) AS [Клиент], NT_SHORT AS [Сеть], SST_SHORT AS [Тип дистрибутива]/*,
		(
			SELECT MAX(UIU_DATE_S)
			FROM 
				dbo.SystemBanksView z WITH(NOEXPAND)
				INNER JOIN USR.USRIBDateView y WITH(NOEXPAND) ON y.UI_ID_BASE = z.InfoBankID
			WHERE z.SystemID = a.SystemID AND y.UI_DISTR = a.DistrNumber AND y.UI_COMP = a.CompNumber
		) AS [Последнее обновление]*/
	FROM 
		Reg.RegNodeSearchView a WITH(NOEXPAND)
		LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = a.SystemID AND DISTR = DistrNumber AND COMP = CompNumber
		LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON ClientID = ID_CLIENT
	WHERE a.DS_REG = 0
		AND a.SystemBaseName NOT IN ('RLAW020')
		AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		AND NT_TECH IN (0, 1)
		AND a.HostId <> 1
		AND a.SubhostName != '490'
		AND 
		(	Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE z.Complect = a.Complect
						AND z.HostID = 1
						AND z.DS_REG <> 0
				)
			OR
			Complect IS NULL
		)
				
	ORDER BY 1, 2, 4
END
