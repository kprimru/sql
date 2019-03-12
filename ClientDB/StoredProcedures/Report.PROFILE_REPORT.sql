USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[PROFILE_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp

	SELECT 
		SystemOrder, DistrNumber, CompNumber, SubhostName,
		ISNULL(ManagerName, SubhostName) AS ManagerName, ServiceName, ISNULL(ClientFullName, Comment) AS Client, 
		a.DistrStr, a.NT_SHORT, ResVersionNumber, UF_DATE, UF_CREATE
		
	INTO #tmp
	
	FROM 
		Reg.RegNodeSearchView a WITH(NOEXPAND)
		INNER JOIN 
			(
				SELECT DISTINCT MainHostID, MainDistrNumber, MainCompNumber
				FROM dbo.RegNodeMainSystemView WITH(NOEXPAND)
			) AS q ON q.MainHostID = a.HostID AND q.MainDistrNumber = a.DistrNumber AND q.MainCompNumber = a.CompNumber
		OUTER APPLY
			(
				SELECT TOP 1 ManagerName, ServiceName, ClientFullName
				FROM 
					dbo.ClientDistrView e WITH(NOEXPAND)
					INNER JOIN dbo.ClientView f WITH(NOEXPAND) ON e.ID_CLIENT = f.ClientID
				WHERE a.SystemID = e.SystemID
					AND a.DistrNumber = e.DISTR
					AND a.CompNumber = e.COMP
			) AS cl
		OUTER APPLY
			(
				SELECT TOP 1 ResVersionNumber, dbo.DateOf(UF_DATE) AS UF_DATE, dbo.DateOf(UF_CREATE) AS UF_CREATE
				FROM
					USR.USRPackage b 
					INNER JOIN USR.USRFile c ON b.UP_ID_USR = c.UF_ID
					INNER JOIN dbo.ResVersionTable d ON c.UF_ID_RES = d.ResVersionID
				WHERE a.SystemID = b.UP_ID_SYSTEM
					AND a.DistrNumber = b.UP_DISTR
					AND a.CompNumber = b.UP_COMP
					AND UF_ACTIVE = 1
				ORDER BY UF_DATE DESC
			) AS usr	
	WHERE a.DS_REG = 0
		AND SST_SHORT NOT IN ('ДИУ', 'ДСП')
		AND
			(
				/*(
					a.SystemShortName IN ('КЮ', 'КБс', 'КБ:Проф')
					AND a.NT_SHORT IN ('лок', 'флэш')
					AND ResVersionNumber NOT IN ('4016.00.07.217001')
				) OR*/
				(
					(
						a.SystemShortName NOT IN ('КЮ', 'КБс', 'КБ:Проф')
						OR a.NT_SHORT NOT IN ('лок', 'флэш')
					)
					AND ResVersionNumber IN ('4016.00.07.217001')
				)
			)
	--ORDER BY SubhostName DESC, ManagerName, ServiceName, ClientFullName, SystemOrder, DistrNumber, CompNumber
	
	SELECT 
		ManagerName AS [Рук-ль], ServiceName AS [СИ], Client AS [Клиент], 
		DistrStr AS [Дистрибутив], NT_SHORT AS [Сеть], 
		ResVersionNumber AS [Техн.модуль], UF_DATE AS [Дата USR], UF_CREATE AS [USR получен]
	FROM #tmp
	ORDER BY SubhostName DESC, ManagerName, ServiceName, Client, SystemOrder, DistrNumber, CompNumber
	
	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp
END
