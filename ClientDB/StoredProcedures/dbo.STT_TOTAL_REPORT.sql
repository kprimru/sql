USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STT_TOTAL_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STT_TOTAL_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STT_TOTAL_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT = NULL,
	@DETAIL		BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @RestrictionType_Id_STT SmallInt;


    DECLARE @ExcludedSystemsTypes Table
        (
            SST_ID  SmallInt PRIMARY KEY CLUSTERED
        );

    DECLARE @ExcludedSystems Table
        (
            SYS_ID  SmallInt PRIMARY KEY CLUSTERED
        );


    DECLARE @ExcludedNetTypes Table
        (
            NT_ID  SmallInt PRIMARY KEY CLUSTERED
        );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
        SET @RestrictionType_Id_STT = (SELECT [Id] FROM [dbo].[Clients:Restrictions->Types] WHERE [Code] = 'STT');

        INSERT INTO @ExcludedSystemsTypes
        SELECT Cast(SetItem AS SmallInt)
        FROM dbo.NamedSetItemsSelect('Din.SystemType', 'Не отправлять STT');

        INSERT INTO @ExcludedSystems
        SELECT Cast(SetItem AS SmallInt)
        FROM dbo.NamedSetItemsSelect('dbo.SystemTable', 'Не отправлять STT');

        INSERT INTO @ExcludedNetTypes
        SELECT Cast(SetItem AS SmallInt)
        FROM dbo.NamedSetItemsSelect('Din.NetType', 'Не отправлять STT');

		SET @END = DATEADD(DAY, 1, @END)

		DECLARE @HOST	INT

		SELECT @HOST = HostID
		FROM dbo.Hosts
		WHERE HostReg = 'LAW'

		DECLARE @SYSTEM	INT

		SELECT @SYSTEM = SystemID
		FROM dbo.SystemTable
		WHERE SystemBaseName = 'RGN'

		IF OBJECT_ID('tempdb..#ip') IS NOT NULL
			DROP TABLE #ip

		CREATE TABLE #ip
			(
				SYS		SMALLINT,
				DISTR	INT,
				COMP	TINYINT
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(NVARCHAR(128), NEWID()) + '] ON #ip(DISTR, SYS, COMP)'
		EXEC (@SQL)

		INSERT INTO #ip(SYS, DISTR, COMP)
			SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
			FROM dbo.IPSTTView
			WHERE CSD_START >= @BEGIN AND CSD_START < @END

		DECLARE @SH	NVARCHAR(16)
		SET @SH = ISNULL(Maintenance.GlobalSubhostName(), '')

		IF OBJECT_ID('tempdb..#cl') IS NOT NULL
			DROP TABLE #cl

		CREATE TABLE #cl
		(
			ClientID	INT,
			Service		VARCHAR(250),
			Manager		VARCHAR(150),
			STT_COUNT	INT,
			STT_CHECK	BIT,
			--ToDo ???
			--PRIMARY KEY CLUSTERED(ClientId)
		);

		INSERT INTO #cl(ClientID, Service, Manager, STT_COUNT, STT_CHECK)
		SELECT
			c.ClientID,
			ISNULL(
				CASE @SH
					WHEN '' THEN
						CASE SubhostName
							WHEN '' THEN ServiceName
							ELSE SubhostName
						END
					ELSE
						ServiceName
				END, ''),
			ISNULL(
				CASE @SH
					WHEN '' THEN
						CASE SubhostName
							WHEN '' THEN ManagerName
							ELSE ''
						END
					ELSE
						ManagerName
				END, ''),
			CASE
				WHEN STT_COUNT = 0 AND IP_DISTR IS NOT NULL THEN -1
				ELSE STT_COUNT
			END AS STT_COUNT, CASE WHEN d.[Id] IS NULL THEN 1 ELSE 0 END
		FROM
			(
				SELECT
					DistrStr, SubhostName, a.HostID, DistrNumber, CompNumber, a.Comment, SST_SHORT, NT_SHORT, a.SystemOrder,
					(
						SELECT COUNT(DISTINCT OTHER)
						FROM
							dbo.ClientStat z
							INNER JOIN dbo.SystemTable b ON SYS_NUM = SystemNumber
						WHERE a.HostID = b.HostID AND z.DISTR = DistrNumber AND z.COMP = CompNumber
							AND DATE >= @BEGIN
							AND DATE < @END
					) AS STT_COUNT,
					c.DISTR AS IP_DISTR
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
					LEFT OUTER JOIN #ip c ON c.SYS = b.SystemNumber AND c.DISTR = a.DistrNumber AND c.COMP = a.CompNumber
				WHERE DS_REG = 0
					--AND (SubhostName = @SUBHOST OR @SUBHOST IS NULL)
					AND (a.HostID = @HOST OR a.SystemID = @SYSTEM)
					--AND SST_SHORT NOT IN ('ОДД', /*'ДИУ', */'АДМ', 'ДСП')
					AND a.SST_ID NOT IN (SELECT E.SST_ID FROM @ExcludedSystemsTypes AS E)
					AND a.SystemID NOT IN (SELECT E.SYS_ID FROM @ExcludedSystems AS E)
					AND a.NT_ID NOT IN (SELECT E.NT_ID FROM @ExcludedNetTypes AS E)
					--AND a.NT_ID NOT IN ('SKS')
					--AND NT_SHORT NOT IN ('онлайн', 'онлайн2', 'онлайн3', 'мобильная', 'ОВМ (ОД 1)', 'ОВМ (ОД 2)', 'ОВМ (ОД 10)', 'ОВП', 'ОВПИ', 'ОВК', 'ОВМ1', 'ОВМ2', 'ОВК-Ф')
					AND a.Complect LIKE a.SystemBaseName + '%'
			) AS a
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
			LEFT JOIN [dbo].[Clients:Restrictions] AS d ON d.Client_Id = c.ClientID AND d.[Type_Id] = @RestrictionType_Id_STT
		WHERE @SERVICE IS NULL OR ServiceID = @SERVICE
		ORDER BY CASE WHEN ManagerName IS NULL THEN 1 ELSE 2 END, ManagerName, ServiceName, c.ClientFullName, a.SystemOrder, a.DistrStr

		IF @DETAIL = 1
			SELECT *
			FROM #cl
		ELSE
			SELECT
				Service, Manager, CL_COUNT, STT_COUNT,
				CASE WHEN CL_COUNT = CL_EXCLUDE THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, STT_COUNT) / (CL_COUNT - CL_EXCLUDE), 2) END AS PRC,

				CASE WHEN CASE WHEN CL_COUNT = CL_EXCLUDE THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, STT_COUNT) / (CL_COUNT - CL_EXCLUDE), 2) END < 80 THEN 1 ELSE 0 END AS PRC_BAD,
				CASE WHEN CASE WHEN CL_COUNT = CL_EXCLUDE THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, STT_COUNT) / (CL_COUNT - CL_EXCLUDE), 2) END >= 80 THEN 1 ELSE 0 END AS PRC_GOOD,
				CL_TOTAL, STT_TOTAL,
				ROUND(100 * CONVERT(FLOAT, STT_TOTAL) / CL_TOTAL, 2) AS TOTAL_PRC,
				MAN_CL_TOTAL, MAN_STT_TOTAL,
				ROUND(100 * CONVERT(FLOAT, MAN_STT_TOTAL) / MAN_CL_TOTAL, 2) AS MAN_TOTAL_PRC,
				CL_EXCLUDE, EXCLUDE_TOTAL, MAN_EXCLUDE_TOTAL
			FROM
				(
					SELECT
						Service, Manager,
						(
							SELECT COUNT(*)
							FROM #cl b
							WHERE a.Service = b.Service
						) AS CL_COUNT,
						(
							SELECT COUNT(*)
							FROM #cl b
							WHERE a.Service = b.Service
								AND b.STT_CHECK = 0
						) AS CL_EXCLUDE,
						(
							SELECT COUNT(*)
							FROM #cl b
							WHERE a.Service = b.Service
								AND STT_COUNT <> 0
						) AS STT_COUNT,
						(
							SELECT COUNT(*)
							FROM #cl
							WHERE Service IS NOT NULL
						) AS CL_TOTAL,
						(
							SELECT COUNT(*)
							FROM #cl
							WHERE Service IS NOT NULL
								AND STT_CHECK = 0
						) AS EXCLUDE_TOTAL,
						(
							SELECT COUNT(*)
							FROM #cl
							WHERE STT_COUNT <> 0
								AND Service IS NOT NULL
						) AS STT_TOTAL,
						(
							SELECT COUNT(*)
							FROM #cl b
							WHERE a.Manager = b.Manager
						) AS MAN_CL_TOTAL,
						(
							SELECT COUNT(*)
							FROM #cl b
							WHERE a.Manager = b.Manager
								AND STT_CHECK = 0
						) AS MAN_EXCLUDE_TOTAL,
						(
							SELECT COUNT(*)
							FROM #cl b
							WHERE a.Manager = b.Manager
								AND STT_COUNT <> 0
						) AS MAN_STT_TOTAL
					FROM
						(
							SELECT DISTINCT Service, Manager
							FROM #cl
							WHERE Service IS NOT NULL
						) AS a
				) AS z

			ORDER BY Manager, Service

		IF OBJECT_ID('tempdb..#cl') IS NOT NULL
			DROP TABLE #cl

		IF OBJECT_ID('tempdb..#ip') IS NOT NULL
			DROP TABLE #ip

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STT_TOTAL_REPORT] TO rl_stt_report;
GO
