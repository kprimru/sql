USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ZVE_NOT_IMPORT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		SELECT dbo.DistrString(SystemShortName, DISTR, COMP) AS [Дистрибутив], DATE AS [Дата], FIO AS [ФИО], EMAIL, PHONE AS [Телефон], QUEST AS [Вопрос]
	FROM 
		dbo.ClientDutyQuestion a
		INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
	WHERE EXISTS
		(
			SELECT 1
			FROM 
				dbo.ClientDistrView z WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable y ON z.SystemID = y.SystemID
			WHERE z.DISTR = a.DISTR AND z.COMP = a.COMP AND y.SystemNumber = a.SYS			
		) 
		AND
		NOT EXISTS
		(
			SELECT *
			FROM
				dbo.ClientDistrView z WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable y ON z.SystemID = y.SystemID
				INNER JOIN dbo.ClientDutyTable x ON x.ClientID = z.ID_CLIENT
			WHERE z.DISTR = a.DISTR AND z.COMP = a.COMP AND y.SystemNumber = a.SYS
				AND x.CLientDutyQuest = a.QUEST AND x.ClientDUtyDateTime = a.DATE
		)
		
	UNION ALL
	
	SELECT dbo.DistrString(SystemShortName, DISTR, COMP) AS [Дистрибутив], DATE AS [Дата], FIO AS [ФИО], EMAIL, PHONE AS [Телефон], QUEST AS [Вопрос]
	FROM 
		dbo.ClientDutyQuestion a
		INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
	WHERE 
		DATE >= '20170301'		
		AND EXISTS
		(
			SELECT 1
			FROM 
				Reg.RegNodeSearchView z WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable y ON z.SystemID = y.SystemID
			WHERE z.DistrNumber = a.DISTR AND z.CompNumber = a.COMP AND y.SystemNumber = a.SYS			
				AND z.SubhostName = 'Л1'
		) 
		AND
		NOT EXISTS
		(
			SELECT *
			FROM
				dbo.ClientDutyTable x 
			WHERE x.ClientID = 3103
				AND x.CLientDutyQuest = a.QUEST AND x.ClientDUtyDateTime = a.DATE
		)
		
	ORDER BY DATE DESC
END
