USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@EMPTY		BIT = 0
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
        FROM dbo.NamedSetItemsSelect('Din.SystemType', 'Íå îòïðàâëÿòü STT');

        INSERT INTO @ExcludedSystems
        SELECT Cast(SetItem AS SmallInt)
        FROM dbo.NamedSetItemsSelect('dbo.SystemTable', 'Íå îòïðàâëÿòü STT');

        INSERT INTO @ExcludedNetTypes
        SELECT Cast(SetItem AS SmallInt)
        FROM dbo.NamedSetItemsSelect('Din.NetType', 'Íå îòïðàâëÿòü STT');

		IF @SERVICE IS NOT NULL
		BEGIN
			SET @MANAGER = NULL
		END

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
				COMP	TINYINT,
				DATE	DATETIME
			)

		INSERT INTO #ip(SYS, DISTR, COMP, DATE)
			SELECT CSD_SYS, CSD_DISTR, CSD_COMP, MAX(CSD_START)
			FROM dbo.IPSTTView
			WHERE CSD_START >= @BEGIN AND CSD_START < @END
			GROUP BY CSD_SYS, CSD_DISTR, CSD_COMP

		SELECT
			ROW_NUMBER() OVER(ORDER BY c.ClientFullName, a.SystemOrder) AS RN,
			c.ClientID, c.ClientFullName,
			a.SystemOrder, a.DistrStr AS UD_NAME, a.DistrStr AS UD_COMPLECT, NT_SHORT AS NET_TYPE,

			STT_DATE AS LAST_DATE,
			CASE
				WHEN STT_COUNT = 0 AND IP_DISTR IS NOT NULL THEN -1
				ELSE STT_COUNT
			END AS FILE_COUNT
		FROM
			(
				SELECT
					DistrStr, SubhostName, a.HostID, DistrNumber, CompNumber, Comment, SST_SHORT, NT_SHORT, a.SystemOrder,
					(
						SELECT COUNT(DISTINCT OTHER)
						FROM
							dbo.ClientStat z
							INNER JOIN dbo.SystemTable b ON SYS_NUM = SystemNumber
						WHERE a.HostID = b.HostID AND z.DISTR = DistrNumber AND z.COMP = CompNumber
							AND DATE >= @BEGIN
							AND DATE < @END
					) AS STT_COUNT,
					ISNULL((
						SELECT MAX(DATE)
						FROM
							dbo.ClientStat z
							INNER JOIN dbo.SystemTable b ON SYS_NUM = SystemNumber
						WHERE a.HostID = b.HostID AND z.DISTR = DistrNumber AND z.COMP = CompNumber
							AND DATE >= @BEGIN
							AND DATE < @END
					), c.DATE) AS STT_DATE,
					c.DISTR AS IP_DISTR
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
					LEFT OUTER JOIN #ip c ON c.SYS = b.SystemNumber AND c.DISTR = a.DistrNumber AND c.COMP = a.CompNumber
				WHERE DS_REG = 0
					AND (a.HostID = @HOST OR a.SystemID = @SYSTEM)
					AND SST_ID NOT IN (SELECT SST_ID FROM @ExcludedSystemsTypes)
					AND a.SystemID NOT IN (SELECT SST_ID FROM @ExcludedSystems)
					AND a.SystemID NOT IN (SELECT SST_ID FROM @ExcludedNetTypes)
					--AND SST_SHORT NOT IN ('ÎÄÄ', /*'ÄÈÓ', */'ÀÄÌ', 'ÄÑÏ')
					--AND a.SystemBaseName NOT IN ('SKS')
					--AND NT_SHORT NOT IN ('îíëàéí', 'îíëàéí2', 'îíëàéí3', 'ìîáèëüíàÿ', 'ÎÂÌ (ÎÄ 1)', 'ÎÂÌ (ÎÄ 2)', 'ÎÂÌ (ÎÄ 10)', 'ÎÂÏ', 'ÎÂÏÈ', 'ÎÂÊ', 'ÎÂÌ1', 'ÎÂÌ2', 'ÎÂÊ-Ô')
			) AS a
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
			--LEFT OUTER JOIN dbo.ClientTable d ON d.ClientID = c.CLientID
			LEFT JOIN [dbo].[Clients:Restrictions] AS d ON d.Client_Id = c.ClientID AND d.[Type_Id] = @RestrictionType_Id_STT
		WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (
					CASE
						WHEN STT_COUNT = 0 AND IP_DISTR IS NOT NULL THEN -1
						ELSE STT_COUNT
					END = 0 AND d.[Id] IS NULL
					OR
					@EMPTY = 0)
		ORDER BY CASE WHEN ManagerName IS NULL THEN 1 ELSE 2 END, ManagerName, ServiceName, c.ClientFullName, a.SystemOrder, a.DistrStr

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
GRANT EXECUTE ON [dbo].[CLIENT_STAT_REPORT] TO rl_client_stat_report;
GO