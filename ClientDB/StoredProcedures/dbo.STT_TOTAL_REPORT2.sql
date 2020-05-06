USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STT_TOTAL_REPORT2]
	@Start		SmallDateTime,
	@Finish		SmallDateTime,
	@Service	SmallInt        = NULL,
	@Detail	    Bit             = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @CL_TOTAL       Int,
        @EXCLUDE_TOTAL  Int,
        @STT_TOTAL      Int,
        @Subhost	    NVarChar(16);

    DECLARE
        @DebugMessage   NVarChar(2000),
        @DebugDateTime  DateTime;

    DECLARE @Ip Table
	(
		SYS		SmallInt,
		DISTR	Int,
		COMP	TinyInt,
        Primary Key Clustered(DISTR, SYS, COMP)
	);

    DECLARE @Clients Table
	(
        Id          Int Identity(1,1),
		Service	    VarChar(100),
        Manager	    VarChar(100),
        STT_COUNT	Int,
		STT_CHECK	Bit,
		PRIMARY KEY CLUSTERED(Id),
        Unique(Service, Id),
        Unique(Manager, Id)
	);

    DECLARE @Distrs Table
    (
        HostId      SmallInt,
        Distr       Int,
        Comp        TinyInt,
        SubhostName NVarChar(16),
        PRIMARY KEY CLUSTERED(Distr, HostId, Comp)
    );

    DECLARE @ExcludedSystemsTypes Table
    (
        SST_ID  SmallInt PRIMARY KEY CLUSTERED
    );

    DECLARE @SystemsTypes Table
    (
        SST_ID  SmallInt PRIMARY KEY CLUSTERED
    );

    DECLARE @NetTypes Table
    (
        NT_ID  SmallInt PRIMARY KEY CLUSTERED
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @DebugDateTime = GetDate();

		SET @Finish = DATEADD(DAY, 1, @Finish)

        SET @Subhost = ISNULL(Maintenance.GlobalSubhostName(), '')

        INSERT INTO @ExcludedSystemsTypes
        SELECT Cast(SetItem AS SmallInt)
        FROM dbo.NamedSetItemsSelect('Din.SystemType', 'Не учитывать для контроля STT');

        INSERT INTO @SystemsTypes
        SELECT SST_ID
        FROM Din.SystemType
        WHERE SST_ID NOT IN (SELECT SST_ID FROM @ExcludedSystemsTypes)

        INSERT INTO @NetTypes
        SELECT NT_ID
        FROM Din.NetTypeOffline();

        SET @DebugMessage = Cast(DateDiff(Millisecond, @DebugDateTime, GetDate()) AS NVarChar(2000)) +  ' мс. Subhost and refernces';
        PRINT @DebugMessage
        SET @DebugDateTime = GetDate();

		INSERT INTO @Ip(SYS, DISTR, COMP)
		SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
		FROM dbo.IPSTTView
		WHERE CSD_START >= @Start AND CSD_START < @Finish;

        SET @DebugMessage = Cast(DateDiff(Millisecond, @DebugDateTime, GetDate()) AS NVarChar(2000)) +  ' мс. INSERT INTO @Ip';
        SET @DebugDateTime = GetDate();

        INSERT INTO @Distrs
        SELECT R.HostId, R.DistrNumber, R.CompNumber, R.SubhostName
        FROM
        (
            SELECT DISTINCT MainHostId, MainDistrNumber, MainCompNumber
            FROM dbo.RegNodeMainDistrView   AS RM WITH(NOEXPAND)
        ) AS RM
        INNER JOIN Reg.RegNodeSearchView    AS R WITH(NOEXPAND) ON R.HostId = RM.MainHostId
                                                                AND R.DistrNumber = RM.MainDistrNumber
                                                                AND R.CompNumber = RM.MainCompNumber
        INNER JOIN @NetTypes                AS N ON N.NT_ID = R.NT_ID
        INNER JOIN @SystemsTypes            AS S ON S.SST_ID = R.SST_ID
        -- а в прошлом отчет уже не построить?
        WHERE DS_REG = 0;

        SET @DebugMessage = Cast(DateDiff(Millisecond, @DebugDateTime, GetDate()) AS NVarChar(2000)) +  ' мс. INSERT INTO @Distrs';
        PRINT @DebugMessage
        SET @DebugDateTime = GetDate();

		INSERT INTO @Clients(Service, Manager, STT_COUNT, STT_CHECK)
		SELECT
			ISNULL(
				CASE @Subhost
					WHEN '' THEN
						CASE SubhostName
							WHEN '' THEN ServiceName
							ELSE SubhostName
						END
					ELSE
						ServiceName
				END, ''),
			ISNULL(
				CASE @Subhost
					WHEN '' THEN
						CASE SubhostName
							WHEN '' THEN ManagerName
							ELSE ''
						END
					ELSE
						ManagerName
				END, ''),
			CASE
				WHEN STT_COUNT = 0 AND [IsIp] = 1 THEN -1
				ELSE STT_COUNT
			END AS STT_COUNT, STT_CHECK
		FROM @Distrs AS D
        OUTER APPLY
        (
			SELECT
                [STT_COUNT] = COUNT(DISTINCT OTHER)
			FROM dbo.ClientStat         AS CS
			INNER JOIN dbo.SystemTable  AS SS ON CS.SYS_NUM = SS.SystemNumber
			WHERE D.HostID = SS.HostID AND CS.DISTR = D.DISTr AND CS.COMP = D.COMP
				AND CS.DATE >= @Start
				AND CS.DATE < @Finish
		) AS STT
        OUTER APPLY
        (
            SELECT
                [IsIp] = 1
            FROM @Ip                    AS I
            INNER JOIN dbo.SystemTable  AS S ON I.SYS = S.SystemNumber
            WHERE S.HostId = D.HostId
                AND I.DISTR = D.Distr
                AND I.COMP = D.Comp
        ) AS IP
        OUTER APPLY
        (
            SELECT ID_CLIENT
            FROM dbo.ClientDistrView   AS CD WITH(NOEXPAND)
            WHERE D.HostID = CD.HostID
                AND D.DISTR = CD.DISTR
                AND D.COMP = CD.COMP
        ) AS CD
        OUTER APPLY
        (
            SELECT ServiceName, ManagerName
            FROM dbo.ClientView        AS C WITH(NOEXPAND)
            WHERE C.ClientID = CD.ID_CLIENT
        ) AS C
        OUTER APPLY
        (
            SELECT STT_CHECK
            FROM dbo.ClientTable       AS Z
            WHERE Z.ClientId = CD.ID_CLIENT
        ) AS Z
        OPTION(RECOMPILE);

        SET @DebugMessage = Cast(DateDiff(Millisecond, @DebugDateTime, GetDate()) AS NVarChar(2000)) +  ' мс. INSERT INTO @Clients';
        PRINT @DebugMessage
        SET @DebugDateTime = GetDate();

        SELECT @CL_TOTAL = COUNT(*)
		FROM @Clients AS B
		WHERE B.Service IS NOT NULL;

		SELECT @EXCLUDE_TOTAL = COUNT(*)
		FROM @Clients AS B
		WHERE B.Service IS NOT NULL
			AND B.STT_CHECK = 0;

		SELECT @STT_TOTAL = COUNT(*)
		FROM @Clients AS B
		WHERE B.STT_COUNT <> 0
			AND B.Service IS NOT NULL;

        SET @DebugMessage = Cast(DateDiff(Millisecond, @DebugDateTime, GetDate()) AS NVarChar(2000)) +  ' мс. Предварительные COUNT(*)';
        PRINT @DebugMessage
        SET @DebugDateTime = GetDate();

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
                CL_COUNT, CL_EXCLUDE, STT_COUNT, CL_TOTAL = @CL_TOTAL, EXCLUDE_TOTAL = @EXCLUDE_TOTAL, STT_TOTAL = @STT_TOTAL, MAN_CL_TOTAL, MAN_EXCLUDE_TOTAL, MAN_STT_TOTAL
			FROM
			(
				SELECT DISTINCT Service, Manager
				FROM @Clients
				WHERE Service IS NOT NULL
			) AS A
            OUTER APPLY
            (
				SELECT CL_COUNT = COUNT(*)
				FROM @Clients AS B
				WHERE A.Service = B.Service
			) AS CL_CNT
            OUTER APPLY
			(
				SELECT CL_EXCLUDE = COUNT(*)
				FROM @Clients AS B
				WHERE A.Service = B.Service
					AND B.STT_CHECK = 0
			) AS CL_EXCL
            OUTER APPLY
			(
				SELECT STT_COUNT = COUNT(*)
				FROM @Clients AS B
				WHERE A.Service = B.Service
					AND B.STT_COUNT <> 0
			) AS STT_CNT
            OUTER APPLY
			(
				SELECT MAN_CL_TOTAL = COUNT(*)
				FROM @Clients AS B
				WHERE A.Manager = B.Manager
			) AS MAN_CL_TTL
            OUTER APPLY
			(
				SELECT MAN_EXCLUDE_TOTAL = COUNT(*)
				FROM @Clients AS B
				WHERE A.Manager = B.Manager
					AND B.STT_CHECK = 0
			) AS MAN_EX_TTL
            OUTER APPLY
			(
				SELECT MAN_STT_TOTAL = COUNT(*)
				FROM @Clients AS B
				WHERE A.Manager = B.Manager
					AND B.STT_COUNT <> 0
			) AS MAN_STT_TTL
		) AS z
		ORDER BY Manager, Service;

        SET @DebugMessage = Cast(DateDiff(Millisecond, @DebugDateTime, GetDate()) AS NVarChar(2000)) +  ' мс. TOTAL RESULT';
        PRINT @DebugMessage
        SET @DebugDateTime = GetDate();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
