USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[KRF_INSTALL]
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
			ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], a.DistrStr AS [Дистрибутив],
			ISNULL(ClientFullName, Comment) AS [Клиент], NT_SHORT AS [Сеть], SST_SHORT AS [Тип дистрибутива]
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
					AND Complect NOT LIKE 'ROS%'
					AND Complect NOT LIKE 'BUHL%'
					AND Complect NOT LIKE 'BUHUL%'
					AND Complect NOT LIKE 'JUR%'
					AND Complect NOT LIKE 'BUD%'
					AND Complect NOT LIKE 'MBP%'
					AND Complect NOT LIKE 'BUDU%'
					AND Complect NOT LIKE 'BVP%'
					AND Complect NOT LIKE 'JURP%'
					AND Complect NOT LIKE 'BUDP%'
					AND Complect NOT LIKE 'KRF%'
					AND Complect NOT LIKE 'BBKZ%'
					AND Complect NOT LIKE 'UBKZ%'
					AND Complect NOT LIKE 'UMKZ%'
					AND Complect NOT LIKE 'SKBP%'
					AND Complect NOT LIKE 'SKBO%'
					AND Complect NOT LIKE 'SKBB%'
					AND Complect NOT LIKE 'SKJE%'
					AND Complect NOT LIKE 'SKJP%'
					AND Complect NOT LIKE 'SKJO%'
					AND Complect NOT LIKE 'SKJB%'
					AND Complect NOT LIKE 'SKUE%'
					AND Complect NOT LIKE 'SKUP%'
					AND Complect NOT LIKE 'SKUO%'
					AND Complect NOT LIKE 'SKUB%'
					AND Complect NOT LIKE 'SBOE%'
					AND Complect NOT LIKE 'SBOP%'
					AND Complect NOT LIKE 'SBOO%'
					AND Complect NOT LIKE 'SBOB%'
					AND Complect NOT LIKE 'SPK-V%'
					AND Complect NOT LIKE 'SPK-IV%'
					AND Complect NOT LIKE 'SPK-III%'
					AND Complect NOT LIKE 'SPK-II%'
					AND Complect NOT LIKE 'SPK-I%'
					AND Complect NOT LIKE 'SKBEM%'
					AND Complect NOT LIKE 'SKJEM%'
					AND Complect NOT LIKE 'SKUEM%'
					AND Complect NOT LIKE 'SBOEM%'
					AND Complect NOT LIKE 'SKZB%'
					AND Complect NOT LIKE 'SKZO%'
					AND Complect NOT LIKE 'RGN%'
					AND Complect NOT LIKE 'RLAW%'
					AND Complect NOT LIKE 'NBU%'
					AND Complect NOT LIKE 'SKS%'
				)

		UNION ALL

		SELECT
			ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], a.DistrStr AS [Дистрибутив],
			ISNULL(ClientFullName, Comment) AS [Клиент], NT_SHORT AS [Сеть], SST_SHORT AS [Тип дистрибутива]
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
			ISNULL(ClientFullName, Comment) AS [Клиент], NT_SHORT AS [Сеть], SST_SHORT AS [Тип дистрибутива]
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[KRF_INSTALL] TO rl_report;
GO