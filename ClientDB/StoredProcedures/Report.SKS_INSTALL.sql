USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[SKS_INSTALL]
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

        DECLARE @Distrs Table
        (
            Host_Id     SmallInt,
            Distr       Int,
            Comp        TinyInt,
            SubhostName VarChar(20),
            MainDistr   VarChar(100),
            MainNet     VarChar(100),
            MainType    VarChar(100),
            SksDistr    VarChar(100),
            ClientName  VarChar(256),
            ServiceName VarChar(256),
            ManagerName VarChar(256)
            Primary Key Clustered(Distr, Host_Id, Comp)
        );

        DECLARE @SksDistrs Table
        (
            Host_Id     SmallInt,
            Distr       Int,
            Comp        TinyInt,
            SubhostName VarChar(20),
            SksDistr    VarChar(100),
            MainDistr   VarChar(100),
            ClientName  VarChar(256),
            ServiceName VarChar(256),
            ManagerName VarChar(256)
            Primary Key Clustered(Distr, Host_Id, Comp)
        );

        INSERT INTO @Distrs(Host_Id, Distr, Comp, SubhostName, MainDistr, MainNet, MainType)
        --SELECT R.DistrStr, R.SST_SHORT, R.NT_SHORT, R.Comment
        SELECT R.HostID, R.DistrNumber, R.CompNumber, R.SubhostName, R.DistrStr, R.NT_SHORT, R.SST_SHORT
        FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
        CROSS APPLY
        (
            SELECT TOP (1) RP.RPR_DATE_S
            FROM dbo.RegProtocol AS RP
            WHERE RP.RPR_ID_HOST = R.HostID
                AND RP.RPR_DISTR = R.DistrNumber
                AND RP.RPR_COMP = R.CompNumber
            ORDER BY RPR_DATE_S
        ) AS RP
        WHERE R.NT_TECH IN (3, 7, 9) -- ToDo - именованное множество
            AND RP.RPR_DATE_S >= '20201228'
            AND R.HostID = 1
            AND R.DS_REG = 0
            AND Cast(RegisterDate AS SmallDateTime) >= '20201228';

        INSERT INTO @SksDistrs(Host_Id, Distr, Comp, SubhostName, SksDistr)
        SELECT R.HostID, R.DistrNumber, R.CompNumber, R.SubhostName, R.DistrStr
        FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
        CROSS APPLY
        (
            SELECT TOP (1) RP.RPR_DATE_S
            FROM dbo.RegProtocol AS RP
            WHERE RP.RPR_ID_HOST = R.HostID
                AND RP.RPR_DISTR = R.DistrNumber
                AND RP.RPR_COMP = R.CompNumber
            ORDER BY RPR_DATE_S
        ) AS RP
        WHERE R.SystemBaseName = 'SKS'
            AND R.DS_REG = 0;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            SksDistr = S.DistrStr
        FROM @Distrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName = 'SKS'
                AND R.DS_REG = 0
        ) AS S
        WHERE D.[SubhostName] = ''
            AND D.SksDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            MainDistr = S.DistrStr
        FROM @SksDistrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName != 'SKS'
                AND R.DS_REG = 0
                AND R.NT_TECH IN (3, 7, 9) -- ToDo заменить на именованное множество
        ) AS S
        WHERE D.[SubhostName] = ''
            AND D.MainDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            SksDistr = S.DistrStr
        FROM @Distrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\ART].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\ART].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\ART].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName = 'SKS'
                AND R.DS_REG = 0
        ) AS S
        WHERE D.[SubhostName] = 'М'
            AND D.SksDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            MainDistr = S.DistrStr
        FROM @SksDistrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\ART].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\ART].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\ART].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName != 'SKS'
                AND R.DS_REG = 0
                AND R.NT_TECH IN (3, 7, 9) -- ToDo заменить на именованное множество
        ) AS S
        WHERE D.[SubhostName] = 'М'
            AND D.MainDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            SksDistr = S.DistrStr
        FROM @Distrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\NKH].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\NKH].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\NKH].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName = 'SKS'
                AND R.DS_REG = 0
        ) AS S
        WHERE D.[SubhostName] = 'Н1'
            AND D.SksDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            MainDistr = S.DistrStr
        FROM @SksDistrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\NKH].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\NKH].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\NKH].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName != 'SKS'
                AND R.DS_REG = 0
                AND R.NT_TECH IN (3, 7, 9) -- ToDo заменить на именованное множество
        ) AS S
        WHERE D.[SubhostName] = 'Н1'
            AND D.MainDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            SksDistr = S.DistrStr
        FROM @Distrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\USS].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\USS].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\USS].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName = 'SKS'
                AND R.DS_REG = 0
        ) AS S
        WHERE D.[SubhostName] = 'У1'
            AND D.SksDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            MainDistr = S.DistrStr
        FROM @SksDistrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\USS].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\USS].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\USS].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName != 'SKS'
                AND R.DS_REG = 0
                AND R.NT_TECH IN (3, 7, 9) -- ToDo заменить на именованное множество
        ) AS S
        WHERE D.[SubhostName] = 'У1'
            AND D.MainDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            SksDistr = S.DistrStr
        FROM @Distrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\SLV].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\SLV].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\SLV].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName = 'SKS'
                AND R.DS_REG = 0
        ) AS S
        WHERE D.[SubhostName] = 'Л1'
            AND D.SksDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        UPDATE D SET
            ClientName = C.ClientFullName,
            ServiceName = C.ServiceName,
            ManagerName = C.ManagerName,
            MainDistr = S.DistrStr
        FROM @SksDistrs D
        CROSS APPLY
        (
            SELECT TOP (1)
                CD.ID_CLIENT,
                C.ClientFullName,
                C.ServiceName,
                C.ManagerName
            FROM [PC276-SQL\SLV].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN [PC276-SQL\SLV].[ClientDB].dbo.ClientView AS C WITH(NOEXPAND) ON CD.ID_CLIENT = C.ClientID
            WHERE CD.HostID = D.Host_Id
                AND CD.DISTR = D.Distr
                AND CD.COMP = D.Comp
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) R.DistrStr
            FROM [PC276-SQL\SLV].[ClientDB].dbo.ClientDistrView AS CD WITH(NOEXPAND)
            INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
            WHERE CD.ID_CLIENT = C.ID_CLIENT
                AND R.SystemBaseName != 'SKS'
                AND R.DS_REG = 0
                AND R.NT_TECH IN (3, 7, 9) -- ToDo заменить на именованное множество
        ) AS S
        WHERE D.[SubhostName] = 'Л1'
            AND D.MainDistr IS NULL
            AND S.DistrStr IS NOT NULL;

        SELECT
            [Клиент] = IsNull(ClientName, R.Comment),
            [Подхост]   = D.[SubhostName],
            [РГ] = IsNull(ManagerName, D.SubhostName),
            [СИ] = IsNull(ServiceName, D.SubhostName),
            [Осн.Дистрибутив|Номер] = MainDistr,
            [Осн.Дистрибутив|Сеть] = MainNet,
            [Осн.Дистрибутив|Тип] = MainType,
            [Дистрибутив СКС] = SksDistr
        FROM @Distrs AS D
        LEFT JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON D.Host_Id = R.HostId AND R.DistrNumber = D.Distr AND R.CompNumber = D.Comp
        WHERE D.SksDistr IS NULL

        UNION ALL

        SELECT
            [Клиент] = IsNull(ClientName, R.Comment),
            [Подхост]   = D.[SubhostName],
            [РГ] = IsNull(ManagerName, D.SubhostName),
            [СИ] = IsNull(ServiceName, D.SubhostName),
            [Осн.Дистрибутив|Номер] = MainDistr,
            [Осн.Дистрибутив|Сеть] = NULL,
            [Осн.Дистрибутив|Тип] = NULL,
            [Дистрибутив СКС] = SksDistr
        FROM @SksDistrs AS D
        LEFT JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON D.Host_Id = R.HostId AND R.DistrNumber = D.Distr AND R.CompNumber = D.Comp
        WHERE MainDistr IS NULL

        ORDER BY
            D.SubhostName, [РГ], [СИ], [Клиент];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[SKS_INSTALL] TO rl_report;
GO