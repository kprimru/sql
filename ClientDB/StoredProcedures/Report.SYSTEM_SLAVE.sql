USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SYSTEM_SLAVE]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		dbo.DistrString(z.SystemShortName, DistrNumber, CompNumber) AS [Дистрибутив ЖК], Comment AS [Название клиента в РЦ], 
		Systems AS [Подчиненные системы в комплекте], ManagerName AS [Рук-ль], a.RegisterDate AS [Дата регистрации]
	FROM
		(
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('CMT', 'QSA', 'ARB')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'MBP'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('CMT', 'QSA', 'ARB')
					)
					
			UNION ALL

			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('CMT', 'ARB')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'JUR'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('CMT', 'ARB')
					)
					
			UNION ALL
					
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('BORG', 'ARB')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'BUD'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('BORG', 'ARB')
					)
					
			UNION ALL
					
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('BORG')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'BUDU'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('BORG')
					)
			
			UNION ALL
			
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'BORG', 'ARB', 'CMT', 'QSA')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'BUDP'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'BORG', 'ARB', 'CMT', 'QSA')
					)
		
			UNION ALL
			
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'ARB', 'CMT', 'FIN')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'BVP'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'ARB', 'CMT', 'FIN')
					)
		
			UNION ALL
			
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'ARB', 'CMT')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND DistrNumber <> 20
				AND SystemName = 'JURP'
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'ARB', 'CMT')
					)
					
			UNION ALL
			
			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('LAW', 'ARB', 'CMT', 'FIN')
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE Service = 0
				AND Complect IS NULL
				AND dbo.SubhostByComment(Comment, DistrNumber) != '490'
				AND DistrType NOT IN ('HSS', 'NCT', 'DSP')

			UNION ALL

			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName = 'PAS'
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE
				Service = 0 AND
				SystemName IN ('BVP', 'BUDP', 'JURP')
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('PAS')
					)

			UNION ALL

			SELECT 
				SystemName, DistrNumber, CompNumber, Comment, RegisterDate,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
						FROM 
							dbo.RegNodeTable b
							INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName = 'FIN'
						ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 1, '')) AS Systems
			FROM dbo.RegNodeTable a
			WHERE
				Service = 0 AND
				SystemName IN ('BUDP')
				AND EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.Complect = b.Complect
							AND b.Service = 0
							AND b.SystemName IN ('FIN')
					)

			) AS a
		INNER JOIN dbo.SystemTable z ON z.SystemBaseName = a.SystemName
		LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.SystemName = b.SystemBaseName AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
		LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
		

			
				
			
	ORDER BY ManagerName, DistrNumber
END
