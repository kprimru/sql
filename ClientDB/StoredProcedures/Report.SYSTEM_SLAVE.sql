USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[SYSTEM_SLAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[SYSTEM_SLAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[SYSTEM_SLAVE]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			dbo.DistrString(z.SystemShortName, DistrNumber, CompNumber) AS [Дистрибутив ЖК], [Сеть] = NT_SHORT, Comment AS [Название клиента в РЦ],
			Systems AS [Подчиненные системы в комплекте], ManagerName AS [Рук-ль], a.RegisterDate AS [Дата регистрации]
		FROM
			(
				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('CMT', 'QSA', 'ARB')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'MBP'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('CMT', 'QSA', 'ARB')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT
								DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('CMT', 'ARB')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'JUR'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('CMT', 'ARB')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('BORG', 'ARB')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'BUD'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('BORG', 'ARB')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('BORG')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'BUDU'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('BORG')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'BORG', 'ARB', 'CMT', 'QSA')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'BUDP'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'BORG', 'ARB', 'CMT', 'QSA')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'ARB', 'CMT', 'FIN')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'BVP'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'ARB', 'CMT', 'FIN')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'ARB', 'CMT')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName = 'JURP'
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'ARB', 'CMT')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('LAW', 'ARB', 'CMT', 'FIN')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND Complect IS NULL
					AND dbo.SubhostByComment2(Comment, DistrNumber, SystemBaseName) != '490'
					AND DistrType NOT IN ('HSS', 'NCT', 'DSP')

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName = 'PAS'
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE
					DS_REG = 0 AND
					SystemBaseName IN ('BVP', 'BUDP', 'JURP')
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('PAS')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName = 'FIN'
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE
					DS_REG = 0 AND
					SystemBaseName IN ('BUDP')
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('FIN')
						)

				UNION ALL

				SELECT
					SystemBaseName, DistrNumber, CompNumber, Comment, RegisterDate, NT_SHORT,
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ','
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('SVRAPS', 'SVA', 'SOJ')
							ORDER BY SystemOrder FOR XML PATH('')
					)), 1, 1, '')) AS Systems
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DS_REG = 0
					AND DistrNumber <> 20
					AND SystemBaseName IN ('SKJP', 'SKUP', 'SBOP')
					AND NT_SHORT IN ('лок', 'флеш')
					AND EXISTS
						(
							SELECT *
							FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
							WHERE a.Complect = b.Complect
								AND b.DS_REG = 0
								AND b.SystemBaseName IN ('SVRAPS', 'SVA', 'SOJ')
						)
				) AS a
			INNER JOIN dbo.SystemTable z ON z.SystemBaseName = a.SystemBaseName
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.SystemBaseName = b.SystemBaseName AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID





		ORDER BY ManagerName, DistrNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[SYSTEM_SLAVE] TO rl_report;
GO
