USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[PROFILE_PROBLEM]
	@PARAM NVARCHAR(MAX) = NULL
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
			[Месяц], [Рук-ль/подхост], [СИ], [Клиент], [Дистрибутив], [Системы в комплекте], [Сеть],
			[Кол-во пользователей], [Кол-во ошибок], [% неверных профилей], [% неверных профилей от КЦ],
			[Информация о профилях]
		FROM
			(
				SELECT
					f.START, SubhostName, ServiceName, ClientFullName,
					f.NAME AS [Месяц],
					ISNULL(ManagerName, SubhostName) AS [Рук-ль/подхост], ServiceName AS [СИ], ISNULL(CLientFullName, Comment) AS [Клиент],
					d.DistrStr AS [Дистрибутив],
					REVERSE(STUFF(REVERSE(
						(
							SELECT DistrStr + ', '
							FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
							WHERE z.Complect = d.Complect AND z.ID <> d.ID
								AND z.DS_REG = 0
							ORDER BY SystemOrder, DistrNumber, CompNumber FOR XML PATH('')
						)), 1, 2, '')) AS [Системы в комплекте],
					NET AS [Сеть], USR_COUNT AS [Кол-во пользователей], ERR_COUNT AS [Кол-во ошибок],
					ROUND(
						(1.0 - CONVERT(DECIMAL(8, 2), (
							SELECT SUM(CNT)
							FROM
								(
									SELECT
										z.ID_MASTER, y.NAME,
										CASE
											WHEN y.NAME = 'Бухгалтерия и кадры'
												AND EXISTS
													(
														SELECT *
														FROM Reg.RegNodeSearchView q
														WHERE q.Complect = d.Complect
															AND q.DS_REG = 0
															AND q.SystemBaseName IN ('FIN', 'QSA', 'BUHL', 'BUHUL', 'BVP', 'BUDP', 'JURP', 'MBP')
													) THEN z.CNT
											WHEN y.NAME = 'Юрист'
												AND EXISTS
													(
														SELECT *
														FROM Reg.RegNodeSearchView q
														WHERE q.Complect = d.Complect
															AND q.DS_REG = 0
															AND q.SystemBaseName IN ('CMT', 'JUR', 'BVP', 'BUDP', 'JURP', 'MBP')
													) THEN z.CNT
											WHEN y.NAME = 'Бухгалтерия и кадры БО'
												AND EXISTS
													(
														SELECT *
														FROM Reg.RegNodeSearchView q
														WHERE q.Complect = d.Complect
															AND q.DS_REG = 0
															AND q.SystemBaseName IN ('BORG', 'BUDP', 'BUD')
													) THEN z.CNT
											WHEN y.NAME = 'Кадры'
												AND EXISTS
													(
														SELECT *
														FROM Reg.RegNodeSearchView q
														WHERE q.Complect = d.Complect
															AND q.DS_REG = 0
															AND q.SystemBaseName IN ('CMT', 'JUR', 'BVP', 'BUDP', 'JURP', 'MBP', 'FIN', 'QSA', 'BUHL', 'BUHUL')
													) THEN z.CNT
											WHEN y.NAME = 'Специалист по закупкам'
												AND EXISTS
													(
														SELECT *
														FROM Reg.RegNodeSearchView q
														WHERE q.Complect = d.Complect
															AND q.DS_REG = 0
															AND q.SystemBaseName IN ('BORG', 'BUDP', 'BUD', 'CMT', 'JUR', 'BVP', 'JURP', 'MBP')
													) THEN z.CNT
											WHEN y.NAME = 'Универсальный' THEN z.CNT
											ELSE 0
										END	AS CNT
									FROM
										dbo.DistrProfileDetail z
										INNER JOIN dbo.ProfileType y ON z.ID_PROFILE = y.ID
									WHERE z.ID_MASTER = a.ID
								) AS o_O
							WHERE o_O.ID_MASTER = a.ID
						)) /
						USR_COUNT) * 100, 2) AS [% неверных профилей],
					PROBLEM_PRC AS [% неверных профилей от КЦ],
					REVERSE(STUFF(REVERSE((
						SELECT y.NAME + ' - ' + CONVERT(NVARCHAR(64), z.CNT) + CHAR(10)
						FROM
							dbo.DistrProfileDetail z
							INNER JOIN dbo.ProfileType y ON z.ID_PROFILE = y.ID
						WHERE z.ID_MASTER = a.ID
						ORDER BY z.ID FOR XML PATH('')
					)), 1, 1, '')) AS [Информация о профилях]
				FROM
					dbo.DistrProfile a
					INNER JOIN Common.Period f ON f.ID = a.ID_PERIOD
					INNER JOIN dbo.SystemTable e ON e.SystemShortName = a.SYS_NAME
					INNER JOIN Reg.RegNodeSearchView d WITH(NOEXPAND) ON a.DISTR = d.DistrNumber AND a.COMP = d.CompNumber AND e.HostID = d.HostID
					LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP AND e.HostID = b.HostID
					LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
			) AS o_O
		WHERE [% неверных профилей] <> 0
		ORDER BY START DESC, SubhostName, [Рук-ль/подхост], ServiceName, ClientFullName

		/*
		SELECT
			f.NAME AS [Месяц],
			ISNULL(ManagerName, SubhostName) AS [Рук-ль/подхост], ServiceName AS [СИ], ISNULL(CLientFullName, Comment) AS [Клиент],
			d.DistrStr AS [Дистрибутив],
			REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ', '
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE z.Complect = d.Complect AND z.ID <> d.ID
					ORDER BY SystemOrder, DistrNumber, CompNumber FOR XML PATH('')
				)), 1, 2, '')) AS [Системы в комплекте],
			NET AS [Сеть], USR_COUNT AS [Кол-во пользователей], ERR_COUNT AS [Кол-во ошибок],
			PROBLEM_PRC AS [% неверных профилей],
			REVERSE(STUFF(REVERSE((
				SELECT y.NAME + ' - ' + CONVERT(NVARCHAR(64), z.CNT) + CHAR(10)
				FROM
					dbo.DistrProfileDetail z
					INNER JOIN dbo.ProfileType y ON z.ID_PROFILE = y.ID
				WHERE z.ID_MASTER = a.ID
				ORDER BY y.ID FOR XML PATH('')
			)), 1, 1, '')) AS [Информация о профилях]
		FROM
			dbo.DistrProfile a
			INNER JOIN Common.Period f ON f.ID = a.ID_PERIOD
			INNER JOIN dbo.SystemTable e ON e.SystemShortName = a.SYS_NAME
			INNER JOIN Reg.RegNodeSearchView d WITH(NOEXPAND) ON a.DISTR = d.DistrNumber AND a.COMP = d.CompNumber AND e.HostID = d.HostID
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP AND e.HostID = b.HostID
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		WHERE PROBLEM_PRC <> 0
		ORDER BY f.START DESC, SubhostName, 2, ServiceName, ClientFullName
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[PROFILE_PROBLEM] TO rl_report;
GO