USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[LARGE_CLIENT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент], 
		(
			SELECT TOP 1 DistrStr + ' (' + DistrTypeName + ')'
			FROM dbo.ClientDistrView z WITH(NOEXPAND)
			WHERE z.ID_CLIENT = a.ClientID
				AND DS_REG = 0
				AND SystemTypeName IN ('Серия А', 'коммерческая', 'Серия К')
				AND 
					(
						z.HostID = 1
						AND 
						z.DistrTypeName IN ('сеть', 'м/с')
							
						OR
							
						z.DistrTypeName = '1/с'
						AND
						z.SystemBaseName IN ('LAW', 'BVP', 'BUDP', 'JURP')
					)
			ORDER BY SystemOrder
		) AS [Дистрибутив],
		(
			SELECT TOP 1 CONVERT(NVARCHAR(64), EventDate, 104) + ' (' + EventCreateUser + ') ' + EventComment
			FROM dbo.EventTable z
			WHERE z.ClientID = a.ClientID
				AND EventActive = 1
				AND EventCreateUser IN
					(
						SELECT ServiceLogin
						FROM dbo.ServiceTable
						WHERE ServiceDismiss IS NULL
					)
				--AND EventDate >= '20170101'
			ORDER BY EventDate DESC
		) AS [Последняя запись истори посещений],
		'' AS [Тендеры],
		(
			SELECT 
				CPT_NAME + ' | ' + 
				CASE ISNULL(CP_SURNAME, '')
					WHEN '' THEN ''
					ELSE CP_SURNAME + ' '
				END + 		
				CASE ISNULL(CP_NAME, '')	
					WHEN '' THEN ''
					ELSE CP_NAME + ' '
				END +
				ISNULL(CP_PATRON, '') + ' | ' + 
				CP_POS + ' | ' + CP_NOTE + ' | ' + 
				CP_PHONE + ' | ' + CP_EMAIL + CHAR(10) 
			FROM
				dbo.ClientPersonal
				LEFT OUTER JOIN dbo.ClientPersonalType ON CPT_ID = CP_ID_TYPE
			WHERE CP_ID_CLIENT = a.ClientID
			ORDER BY ISNULL(CPT_REQUIRED, 0) DESC, CPT_ORDER, CP_SURNAME, CP_NAME FOR XML PATH('')
		) AS [Сотрудники],
		(
			SELECT COUNT(*)
			FROM dbo.CLientStudy z
			WHERE STATUS = 1
				AND z.ID_CLIENT = a.ClientID
				AND DATEPART(YEAR, z.DATE) IN (DATEPART(YEAR, GETDATE()), DATEPART(YEAR, GETDATE()) - 1)
		) AS [Кол-во обучений],
		(
			SELECT COUNT(*)
			FROM dbo.ClientDutyTable z
			WHERE z.ClientID = a.ClientID
				AND z.STATUS = 1
				AND z.ClientDutyDateTime >= DATEADD(MONTH, -3, GETDATE())
		) AS [Кол-во обращений в ДС],
		(
			SELECT TOP 1 CONVERT(NVARCHAR(64), CR_DATE, 104) + ' ' + CR_CONDITION
			FROM dbo.ClientRival z
			WHERE CL_ID = a.ClientID
				AND CR_ACTIVE = 1
			ORDER BY CR_DATE DESC
		) AS [Запись о конкурентах],
		(
			SELECT CONVERT(NVARCHAR(64), DATE, 104) + ' (' + PERSONAL + ') ' + NOTE + CHAR(10)
			FROM dbo.ClientContact z
			WHERE z.ID_CLIENT = a.ClientID
				AND z.STATUS = 1
			ORDER BY DATE DESC FOR XML PATH('')
		) AS [Записи РГ]
	FROM dbo.ClientView a WITH(NOEXPAND)
	WHERE a.ServiceStatusID = 2
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientDistrView z WITH(NOEXPAND)
				WHERE z.ID_CLIENT = a.ClientID
					AND DS_REG = 0
					AND SystemTypeName IN ('Серия А', 'коммерческая', 'Серия К')
					AND 
						(
							z.HostID = 1
							AND 
							z.DistrTypeName IN ('сеть', 'м/с')
							
							OR
							
							z.DistrTypeName = '1/с'
							AND
							z.SystemBaseName IN ('LAW', 'BVP', 'BUDP', 'JURP')
						)
			)		
	ORDER BY ManagerName, ServiceName
END
