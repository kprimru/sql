USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_CLAIM_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	IF IS_MEMBER('rl_study_warning_manager') = 1
		SELECT 
			ID, ID_CLIENT AS ClientID, DATE, STUDY_DATE, MEETING_DATE, ClientFullName + ISNULL(' (' + d.CATEGORY + ')', '') AS ClientFullName, STATUS,
			NOTE = Cast(NOTE AS VarChar(4000)), REPEAT, TeacherName, ServiceName + ' (' + ManagerName + ')' AS ServiceName, CALL_DATE, TEACHER_NOTE, 
			REVERSE(STUFF(REVERSE(
				(
					SELECT z.NOTE + ', '
					FROM dbo.ClientStudyClaimPeople z
					WHERE z.ID_CLAIM = a.ID
						AND z.NOTE <> ''
					FOR XML PATH('')
				)
			), 1, 2, '')) AS PERS_NOTE,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) AS AUTHOR_FILTER,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) + ' ' + ServiceName + ' (' + ManagerName + ')' AS AUTHOR,
			CASE STATUS 
				WHEN 1 THEN 'Активна'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
			END AS STATUS_STR,			
			REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ', '
					FROM
						(
							SELECT DISTINCT g.DistrStr, SystemOrder, DISTR, COMP
							FROM 
								dbo.RegNodeMainSystemView f WITH(NOEXPAND)
								INNER JOIN dbo.ClientDistrView g WITH(NOEXPAND) ON f.MainHostID = g.HostID AND f.MainDistrNumber = g.DISTR AND f.MainCompNumber = g.COMP
							WHERE g.ID_CLIENT = a.ID_CLIENT
								AND NOT EXISTS
									(
										SELECT *
										FROM dbo.ExpDistr z
										WHERE z.ID_HOST = g.HostID AND z.DISTR = g.DISTR AND z.COMP = g.COMP
									)
						) AS o_O
					ORDER BY SystemOrder, DISTR, COMP FOR XML PATH('')
				)), 1, 2, '')) AS ZVE_DISTR		
		FROM 
			dbo.ClientStudyClaim a
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = ID_CLIENT
			LEFT OUTER JOIN dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER
			LEFT OUTER JOIN dbo.ClientTypeAllView d ON d.ClientID = a.ID_CLIENT
		WHERE a.STATUS IN (1, 9)
		ORDER BY DATE DESC
	ELSE IF IS_MEMBER('rl_study_warning_manager') = 1
		SELECT 
			ID, ID_CLIENT AS ClientID, DATE, STUDY_DATE, MEETING_DATE,ClientFullName + ISNULL(' (' + d.CATEGORY + ')', '') AS ClientFullName, STATUS,
			NOTE = Cast(NOTE AS VarChar(4000)), REPEAT, TeacherName, ServiceName + ' (' + ManagerName + ')' AS ServiceName, CALL_DATE, TEACHER_NOTE, 
			REVERSE(STUFF(REVERSE(
				(
					SELECT z.NOTE + ', '
					FROM dbo.ClientStudyClaimPeople z
					WHERE z.ID_CLAIM = a.ID
						AND z.NOTE <> ''
					FOR XML PATH('')
				)
			), 1, 2, '')) AS PERS_NOTE,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) AS AUTHOR_FILTER,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) + ' ' + ServiceName + ' (' + ManagerName + ')' AS AUTHOR,
			CASE STATUS 
				WHEN 1 THEN 'Активна'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
			END AS STATUS_STR,			
			REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ', '
					FROM
						(
							SELECT DISTINCT g.DistrStr, SystemOrder, DISTR, COMP
							FROM 
								dbo.RegNodeMainSystemView f WITH(NOEXPAND)
								INNER JOIN dbo.ClientDistrView g WITH(NOEXPAND) ON f.MainHostID = g.HostID AND f.MainDistrNumber = g.DISTR AND f.MainCompNumber = g.COMP
							WHERE g.ID_CLIENT = a.ID_CLIENT
								AND NOT EXISTS
									(
										SELECT *
										FROM dbo.ExpDistr z
										WHERE z.ID_HOST = g.HostID AND z.DISTR = g.DISTR AND z.COMP = g.COMP
									)
						) AS o_O
					ORDER BY SystemOrder, DISTR, COMP FOR XML PATH('')
				)), 1, 2, '')) AS ZVE_DISTR		
		FROM 
			dbo.ClientStudyClaim a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON ClientID = ID_CLIENT
			LEFT OUTER JOIN dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER
			LEFT OUTER JOIN dbo.ClientTypeAllView d ON d.ClientID = a.ID_CLIENT
		WHERE a.STATUS IN (1, 9) AND b.ManagerName = ORIGINAL_LOGIN() AND a.DATE > DATEADD(DAY, -7, GETDATE())
		ORDER BY DATE DESC
	ELSE 
		SELECT 
			ID, ID_CLIENT AS ClientID, DATE, STUDY_DATE, MEETING_DATE, ClientFullName + ISNULL(' (' + d.CATEGORY + ')', '') AS ClientFullName, STATUS,
			NOTE = Cast(NOTE AS VarChar(4000)), REPEAT, TeacherName, ServiceName + ' (' + ManagerName + ')' AS ServiceName, CALL_DATE, TEACHER_NOTE, 
			REVERSE(STUFF(REVERSE(
				(
					SELECT z.NOTE + ', '
					FROM dbo.ClientStudyClaimPeople z
					WHERE z.ID_CLAIM = a.ID
						AND z.NOTE <> ''
					FOR XML PATH('')
				)
			), 1, 2, '')) AS PERS_NOTE,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) AS AUTHOR_FILTER,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) + ' ' + ServiceName + ' (' + ManagerName + ')' AS AUTHOR,
			CASE STATUS 
				WHEN 1 THEN 'Активна'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
			END AS STATUS_STR,			
			REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ', '
					FROM
						(
							SELECT DISTINCT g.DistrStr, SystemOrder, DISTR, COMP
							FROM 
								dbo.RegNodeMainSystemView f WITH(NOEXPAND)
								INNER JOIN dbo.ClientDistrView g WITH(NOEXPAND) ON f.MainHostID = g.HostID AND f.MainDistrNumber = g.DISTR AND f.MainCompNumber = g.COMP
							WHERE g.ID_CLIENT = a.ID_CLIENT
								AND NOT EXISTS
									(
										SELECT *
										FROM dbo.ExpDistr z
										WHERE z.ID_HOST = g.HostID AND z.DISTR = g.DISTR AND z.COMP = g.COMP
									)
						) AS o_O
					ORDER BY SystemOrder, DISTR, COMP FOR XML PATH('')
				)), 1, 2, '')) AS ZVE_DISTR		
		FROM 
			dbo.ClientStudyClaim a
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = ID_CLIENT
			LEFT OUTER JOIN dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER	
			LEFT OUTER JOIN dbo.ClientTypeAllView d ON d.ClientID = a.ID_CLIENT		
		WHERE a.STATUS IN (1, 9)
		ORDER BY DATE DESC
END