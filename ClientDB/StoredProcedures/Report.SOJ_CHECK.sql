USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[SOJ_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr

	CREATE TABLE #usr(UF_ID UNIQUEIDENTIFIER PRIMARY KEY)

	INSERT INTO #usr(UF_ID)
		SELECT UF_ID
		FROM USR.USRActiveView
		WHERE UF_DATE >= '20171001'

	SELECT 
		ISNULL(ManagerName, SubhostName) AS [Рук-ль/Подхост], ServiceName AS [СИ], 
		ISNULL(ClientFullName, Comment) AS [Клиент], t.DistrStr AS [Дистрибутив], 
		NT_SHORT AS [Сеть], SST_SHORT AS [Тип], 
		OLD_SOJ_EXISTS AS [Старый ИБ СОЮ], NEW_SOJ_EXISTS AS [Новые ИБ СОЮ],
		CASE 
			WHEN OLD_SOJ_EXISTS = 0 AND NEW_SOJ_EXISTS = 0 THEN 'ИБ СОЮ отсутствуют'
			WHEN OLD_SOJ_EXISTS = 1 AND NEW_SOJ_EXISTS = 0 THEN 'Только старый ИБ СОЮ'
			WHEN OLD_SOJ_EXISTS = 0 AND NEW_SOJ_EXISTS = 1 THEN 'Только новый ИБ СОЮ'
			WHEN OLD_SOJ_EXISTS = 1 AND NEW_SOJ_EXISTS = 1 THEN 'Установлены оба ИБ СОЮ'
		END AS [Заключение]
	FROM
		(
			SELECT 
				SubhostName, HostID, DistrNumber, CompNumber, Comment, DistrStr, NT_SHORT, SST_SHORT,
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM 
								#usr z
								INNER JOIN USR.USRIB y ON z.UF_ID = y.UI_ID_USR
								INNER JOIN dbo.InfoBankTable x ON x.InfoBankID = y.UI_ID_BASE
							WHERE x.InfoBankName = 'SOJ'
								AND y.UI_DISTR = a.DistrNumber
								AND y.UI_COMP = a.CompNumber
						) THEN 1
						ELSE 0
				END AS OLD_SOJ_EXISTS,
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM 
								#usr z
								INNER JOIN USR.USRIB y ON z.UF_ID = y.UI_ID_USR
								INNER JOIN dbo.InfoBankTable x ON x.InfoBankID = y.UI_ID_BASE
							WHERE x.InfoBankName IN ('SOUR', 'SOUG', 'SOSZ', 'SOSK', 'SOSB', 'SOPV', 'SODV', 'SOCN')
								AND y.UI_DISTR = a.DistrNumber
								AND y.UI_COMP = a.CompNumber
						) THEN 1
						ELSE 0
				END AS NEW_SOJ_EXISTS
			FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
			WHERE SystemBaseName = 'SOJ'
				AND DS_REG = 0
				AND NT_SHORT NOT IN ('ОВК', 'ОВП', 'ОВПИ', 'ОВМ1', 'ОВМ2')
		) AS t
		LEFT OUTER JOIN dbo.ClientDistrView p WITH(NOEXPAND) ON t.DistrNumber = p.DISTR AND t.CompNumber= p.COMP AND t.HostID = p.HostID
		LEFT OUTER JOIN dbo.ClientView q WITH(NOEXPAND) ON q.ClientID = p.ID_CLIENT
	ORDER BY CASE WHEN ManagerName IS NULL THEN 1 ELSE 0 END, SubhostName, ManagerName, ServiceName, ClientFullName, Comment, SystemOrder, DistrNumber


	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
END
