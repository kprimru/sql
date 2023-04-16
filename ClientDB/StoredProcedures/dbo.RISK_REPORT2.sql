USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_REPORT2]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_REPORT2]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[RISK_REPORT2]
	@Managers_IDs		NVarChar(Max),
	@Services_IDs		NVarChar(Max),
	@ClientTypes_IDs	NVarChar(Max),
	@ClientName			NVarCHar(128),
	@Distr				VarChar(128),
	@Systems_IDs		NVarChar(Max),
	@NetTypes_IDs		NVarChar(Max),
	@DateFrom			SmallDateTime,
	@DateTo				SmallDateTime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@CurMonth				UniqueIdentifier,
		@Compliance_Id_HOST		Int;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @Clients Table
		(
			[Identity]				Int		Identity(1,1)	Primary Key Clustered,
			[Client_Id]				Int,
			[Complect_Id]			Int,
			[Complect]				VarChar(128),
			[ComplectReg]			VarChar(128),
			[ComplectHost_Id]		SmallInt,
			[ComplectDistr]			Int,
			[ComplectComp]			TinyInt,
			[DutyCount]				SmallInt,
			[DutyQuestionCount]		SmallInt,
			[DutyHotlineCount]		SmallInt,
			[RivalCount]			SmallInt,
			[StudyCount]			SmallInt,
			[SeminarCount]			SmallInt,
			[UpdatesCount]			SmallInt,
			[LostCount]				SmallInt,
			[DownloadCount]			SmallInt,
			[DownloadBases]			VarChar(Max),
			[OnlineActivityCount]	SmallInt,
			[OfflineEnterCount]		SmallInt,
			[OldRes]				VarChar(128),
			[OldConsExe]			VarChar(128),
			[ComplianceIB]			VarChar(Max),
			[DeliveryCount]			SmallInt,
			[OldEvent]				SmallDateTime,
			[LastPay]				VarChar(128),
			Unique([Client_Id], [Complect])
		);


		DECLARE @Weeks Table
		(
			[ID]		UniqueIdentifier,
			[START]		SmallDateTime,
			[FINISH]	SmallDateTime,
			PRIMARY KEY CLUSTERED(START)
		);

		DECLARE @ResVersions Table
		(
			[ClientID]				Int,
			[ClientFullName]		VarChar(512),
			[ManagerName]			VarChar(256),
			[ServiceName]			VarChar(256),
			[Complect]				VarChar(256),
			[ResVersionNumber]		VarChar(128),
			[ConsExeVersionName]	VarChar(128),
			[KDVersionName]			VarChar(128),
			[UF_DATE]				SmallDateTime,
			[UF_CREATE]				SmallDateTime
		);

		DECLARE @CurPay Table
		(
			[RN]				Int,
			[ClientID]			Int,
			[ClientFullName]	VarChar(512),
			[ServiceName]		VarChar(256),
			[PayType]			VarChar(256),
			[ContractPay]		VarChar(256),
			[PayDate]			SmallDateTime,
			[PAY]				VarChar(128),
			[PRC]				Decimal(8,4),
			[LAST_PAY]			SmallDateTime,
			[PAY_DATES]			VarChar(256),
			[PAY_DELTA]			SmallInt,
			[PAY_ERROR]			SmallInt,
			[DistrStr]			VarChar(256),
			[PAY_DATE_ERROR]	Bit,
			[LAST_MON]			SmallDateTime,
			[LAST_ACT]			SmallDateTime
		);

		INSERT INTO @Weeks
		SELECT ID, START, FINISH
		FROM Common.Period
		WHERE TYPE = 1 AND START BETWEEN @DateFrom AND @DateTo;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO @Weeks';

		INSERT INTO @Clients([Client_Id], [Complect_Id], [Complect], [ComplectReg], [ComplectHost_Id], [ComplectDistr], [ComplectComp])
		SELECT
			C.[ClientID],
			U.[UD_ID],
			U.[DistrStr],
			U.[Complect],
			U.[HostId],
			U.[DistrNumber],
			U.[CompNumber]
		FROM [dbo].[ClientView]						AS C WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() AS S ON C.[ServiceStatusID] = S.[ServiceStatusId]
		OUTER APPLY
		(
			SELECT
				R.[DistrStr],
				R.[HostID],
				R.[DistrNumber],
				R.[CompNumber],
				R.[Complect],
				U.[UD_ID]
			FROM [dbo].[RegNodeComplectClientView] AS R
			LEFT JOIN [USR].[USRActiveView] AS U ON U.[UD_ID_HOST] = R.[HostID] AND U.[UD_DISTR] = R.[DistrNumber] AND U.[UD_COMP] = R.[CompNumber]
			WHERE R.[DS_REG] = 0
				AND R.[ClientID] = C.[ClientID]
		) AS U
		OUTER APPLY
		(
			SELECT TOP (1) [SksComplect] = R.[Complect]
			FROM [dbo].[RegNodeTable] AS R
			WHERE R.[Comment] LIKE 'ОС' + Cast(U.[DistrNumber] AS VarChar(100)) + ' %'
				AND R.[SystemName] = 'SKS'
				AND R.[Service] = 0
		) AS R
		WHERE	(C.[ServiceID] = (SELECT ID FROM dbo.TableIDFromXML(@Services_IDs)) OR @Services_IDs IS NULL)
			AND (C.[ManagerID] IN (SELECT ID FROM dbo.TableIDFromXML(@Managers_IDs)) OR @Managers_IDs IS NULL)
			AND (C.[ClientKind_Id] IN (SELECT ID FROM dbo.TableIDFromXML(@ClientTypes_IDs)) OR @ClientTypes_IDs IS NULL)
			AND (C.[ClientFullName] LIKE @ClientName OR @ClientName IS NULL)
			AND (@Distr IS NULL OR EXISTS(SELECT * FROM [dbo].[ClientDistrView] AS D WHERE D.[ID_CLIENT] = C.[ClientID] AND Cast(D.[DISTR] AS VarChar(128)) LIKE @Distr))
			AND (@NetTypes_IDs IS NULL OR EXISTS(SELECT * FROM [dbo].[ClientDistrView] AS D WHERE D.[ID_CLIENT] = C.[ClientID] AND D.[DistrTypeID] IN (SELECT ID FROM dbo.TableIDFromXML(@NetTypes_IDs))))
			AND (@Systems_IDs IS NULL OR EXISTS(SELECT * FROM [dbo].[ClientDistrView] AS D WHERE D.[ID_CLIENT] = C.[ClientID] AND D.[SystemID] IN (SELECT ID FROM dbo.TableIDFromXML(@Systems_IDs))))
			-- только комплекты для которых нет СКС (либо оффлайн, либо онлайн без СКС, либо сами СКС)
			AND R.[SksComplect] IS NULL
		OPTION(RECOMPILE);

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO @Clients';

		UPDATE C SET
			[DutyCount]				= D.[DutyCount],
			[DutyQuestionCount]		= D.[DutyQuestionCount],
			[DutyHotlineCount]		= D.[DutyHotlineCount]
		FROM @Clients						AS C
		INNER JOIN
		(
			SELECT
				[ClientID],
				[DutyCount]				= Sum(CASE WHEN DDT.[Id] IS NOT NULL THEN 1 ELSE 0 END),
				[DutyQuestionCount]		= Sum(CASE WHEN QDT.[Id] IS NOT NULL THEN 1 ELSE 0 END),
				[DutyHotlineCount]		= Sum(CASE WHEN HDT.[Id] IS NOT NULL THEN 1 ELSE 0 END)
			FROM [dbo].[ClientDutyTable]	AS D
			LEFT JOIN [dbo].[CallDirection@Get]('ОБРАЩЕНИЕ') AS DDT ON DDT.[Id] = D.[ID_DIRECTION]
			LEFT JOIN [dbo].[CallDirection@Get]('ЗВЭ') AS QDT ON QDT.[Id] = D.[ID_DIRECTION]
			LEFT JOIN [dbo].[CallDirection@Get]('ЧАТ') AS HDT ON HDT.[Id] = D.[ID_DIRECTION]
			WHERE D.[STATUS] = 1
				AND D.[ClientDutyDateTime] BETWEEN @DateFrom AND @DateTo
			GROUP BY ClientID
		) AS D ON D.[ClientID] = C.[Client_Id];

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE DutyData';

		UPDATE C SET
			[RivalCount] = R.[RivalCount]
		FROM @Clients AS C
		INNER JOIN
		(
			SELECT
				ClientID		= R.[CL_ID],
				[RivalCount]	= Count(*)
			FROM dbo.ClientRival AS R
			WHERE	CR_ACTIVE = 1
				AND CR_DATE BETWEEN @DateFrom AND @DateTo
			GROUP BY CL_ID
		) AS R ON R.[ClientID] = C.[Client_Id]

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE RivalData';

		UPDATE C SET
			[StudyCount] = S.[StudyCount]
		FROM @Clients AS C
		INNER JOIN
		(
			SELECT
				[ClientID]		= S.[ID_CLIENT],
				[StudyCount]	= Count(*)
			FROM [dbo].[ClientStudy] AS S
			INNER JOIN [dbo].[LessonPlace@Get]('Отчетное') AS LP ON LP.[Id] = S.[ID_PLACE]
			WHERE S.[STATUS] = 1
				AND S.[DATE] BETWEEN @DateFrom AND @DateTo
				AND S.[TEACHED] = 1
			GROUP BY S.[ID_CLIENT]
		) AS S ON S.[ClientID] = C.[Client_Id];

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE StudyData';

		UPDATE C SET
			[SeminarCount] = S.[SeminarCount]
		FROM @Clients AS C
		INNER JOIN
		(
			SELECT
				[ClientID]		= P.[ID_CLIENT],
				[SeminarCount]	= Count(*)
			FROM [Seminar].[Schedule] AS S
			INNER JOIN [Seminar].[Personal] AS P ON P.[ID_SCHEDULE] = S.[ID]
			INNER JOIN [Seminar].[Status] AS SS ON SS.[ID] = P.[ID_STATUS]
			WHERE P.[STATUS] = 1
				AND S.[DATE] BETWEEN @DateFrom AND @DateTo
				AND SS.[INDX] = 1
			GROUP BY P.[ID_CLIENT]
		) AS S ON S.[ClientID] = C.[Client_Id];

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE SeminarData';

		UPDATE C SET
			[UpdatesCount] = U.[UpdatesCount]
		FROM @Clients AS C
		CROSS APPLY
		(
			SELECT
				[UpdatesCount] = Count(*)
			FROM
			(
				SELECT W.[START], W.[FINISH]
				FROM @Weeks						AS W
				INNER JOIN USR.USRIBDateView	AS U WITH(NOEXPAND) ON U.[UD_ID_CLIENT] = C.[Client_Id]
																AND U.[UD_ID] = C.[Complect_Id]
																AND U.[UIU_DATE_S] BETWEEN W.[START] AND W.[FINISH]
				GROUP BY W.[START], W.[FINISH]
			) AS U
		) AS U;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE UpdatesData';

		UPDATE C SET
			[LostCount] = U.[LostCount]
		FROM @Clients AS C
		CROSS APPLY
		(
			SELECT
				[LostCount] = Count(*)
			FROM @Weeks						AS W
			WHERE NOT EXISTS
				(
					SELECT W.[START], W.[FINISH]
					FROM [USR].[USRIBDateView]	AS U WITH(NOEXPAND)
					WHERE U.[UD_ID_CLIENT] = C.[Client_Id]
						AND U.[UD_ID] = C.[Complect_Id]
						AND U.[UIU_DATE_S] BETWEEN W.[START] AND W.[FINISH]
				)
		) AS U;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE LostData';

		UPDATE C SET
			[DownloadCount] = D.[DocumentsCount],
			[DownloadBases] = B.[Bases]
		FROM @Clients AS C
		INNER JOIN
		(
			SELECT
				[ClientID]			= D.[ID_CLIENT],
				[DocumentsCount]	= Count(*)
			FROM [dbo].[ControlDocument]		AS CD
			INNER JOIN [dbo].[SystemTable]		AS S ON S.[SystemNumber] = CD.[SYS_NUM]
			INNER JOIN [dbo].[ClientDistrView]	AS D WITH(NOEXPAND) ON CD.[DISTR] = D.[DISTR] AND CD.[COMP] = D.[COMP] AND D.[HostID] = S.[HostID]
			LEFT JOIN [dbo].[InfoBankTable]		AS IB ON IB.[InfoBankName] = CD.[IB]
			WHERE CD.[DATE_S] BETWEEN @DateFrom AND @DateTo
			GROUP BY D.[ID_CLIENT]
		) AS D ON D.[ClientID] = C.[Client_Id]
		INNER JOIN
		(
			SELECT
				[ClientID]			= B.[ClientID],
				[Bases]				= String_Agg(B.[Base], ',')
			FROM
			(
				SELECT DISTINCT
					[ClientID]			= D.[ID_CLIENT],
					[Base]				= IsNull(IB.[InfoBankShortName], CD.[IB])
				FROM [dbo].[ControlDocument]		AS CD
				INNER JOIN [dbo].[SystemTable]		AS S ON S.[SystemNumber] = CD.[SYS_NUM]
				INNER JOIN [dbo].[ClientDistrView]	AS D WITH(NOEXPAND) ON CD.[DISTR] = D.[DISTR] AND CD.[COMP] = D.[COMP] AND D.[HostID] = S.[HostID]
				LEFT JOIN [dbo].[InfoBankTable]		AS IB ON IB.[InfoBankName] = CD.[IB]
				WHERE CD.[DATE_S] BETWEEN @DateFrom AND @DateTo
			) AS B
			GROUP BY B.[ClientID]
		) AS B ON B.[ClientID] = C.[Client_Id]

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE DownloadData';

		UPDATE C SET
			[OnlineActivityCount] = U.[ActivityCount]
		FROM @Clients AS C
		CROSS APPLY
		(
			SELECT
				[ActivityCount] = Count(*)
			FROM
			(
				SELECT DISTINCT W.[ID]
				FROM [dbo].[OnlineActivity]	AS A
				INNER JOIN @Weeks			AS W ON A.[ID_WEEK] = W.[ID]
				WHERE A.[ID_HOST] = C.[ComplectHost_Id]
					AND A.[DISTR] = C.[ComplectDistr]
					AND A.[COMP] = C.[ComplectComp]
					AND A.[ACTIVITY] = 1
			) AS A
		) AS U;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE OnlineActivityData';

		UPDATE C SET
			[OfflineEnterCount] = U.[OfflineEnterCount]
		FROM @Clients AS C
		CROSS APPLY
		(
			SELECT
				[OfflineEnterCount] = Count(*)
			FROM
			(
				SELECT DISTINCT W.[ID]
				FROM [dbo].[ClientStatDetail]	AS A
				INNER JOIN @Weeks				AS W ON A.[WeekId] = W.[ID]
				WHERE A.[HostId] = C.[ComplectHost_Id]
					AND A.[DISTR] = C.[ComplectDistr]
					AND A.[COMP] = C.[ComplectComp]
					AND A.[EnterSum] > 0
			) AS A
		) AS U
		WHERE C.[ComplectReg] NOT LIKE 'SKS%';

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE OfflineActivityData';

		INSERT INTO @ResVersions
		SELECT
			[ClientID],
			[ClientFullName],
			[ManagerName],
			[ServiceName],
			[Complect],
			[ResVersionNumber],
			[ConsExeVersionName],
			[KDVersionName],
			[UF_DATE],
			[UF_CREATE]
		FROM [Usr].[ResVersion@Check]
		(
			NULL,
			NULL,
			NULL,
			NULL,
			1,
			NULL,
			NULL,
			NULL,
			NULL
		);

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO @ResVersions';

		UPDATE C SET
			[OldRes] = R.[ResVersionNumber]
		FROM @Clients AS C
		INNER JOIN @ResVersions AS R ON R.[ClientID] = C.[Client_Id] AND R.[Complect] = C.[ComplectReg]
		WHERE R.[ResVersionNumber] != '';

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE ResVersionData';

		UPDATE C SET
			[OldConsExe] = R.[ConsExeVersionName]
		FROM @Clients AS C
		INNER JOIN @ResVersions AS R ON R.[ClientID] = C.[Client_Id] AND R.[Complect] = C.[ComplectReg]
		WHERE R.[ConsExeVersionName] != '';

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE ConsExeVersionData';

		SELECT @Compliance_Id_HOST = ComplianceTypeID
		FROM dbo.ComplianceTypeTable
		WHERE ComplianceTypeName = '#HOST';

		UPDATE C SET
			[ComplianceIB] = U.[ComplianceIB]
		FROM @Clients AS C
		CROSS APPLY
		(
			SELECT [ComplianceIB] = String_Agg(IB.[InfoBankShortName], ',')
			FROM
			(
				SELECT DISTINCT IB.[InfoBankShortName]
				FROM [USR].[USRActiveView]			AS A
				INNER JOIN [USR].[USRIB]			AS UIB ON UIB.[UI_ID_USR] = A.[UF_ID]
				INNER JOIN [dbo].[InfoBankTable]	AS IB ON IB.[InfoBankID] = UIB.[UI_ID_BASE]
				WHERE A.[UD_ID] = C.[Complect_Id]
					AND UIB.[UI_ID_COMP] = @Compliance_Id_HOST
			) AS IB
		) AS U;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE ComlianceData';

		UPDATE C SET
			[DeliveryCount] = S.[DeliveryCount]
		FROM @Clients AS C
		INNER JOIN
		(
			SELECT
				[ClientID]		= S.[ID_CLIENT],
				[DeliveryCount]	= Count(*)
			FROM [dbo].[ClientDelivery] AS S
			WHERE S.[FINISH] IS NULL
			GROUP BY S.[ID_CLIENT]
		) AS S ON S.[ClientID] = C.[Client_Id];

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE DeliveryData';

		UPDATE C SET
			[OldEvent] = E.[EventDate]
		FROM @Clients AS C
		OUTER APPLY
		(
			SELECT TOP (1) E.[EventDate]
			FROM [dbo].[EventTable] AS E
			WHERE E.[ClientID] = C.[Client_Id]
				AND E.[EventDate] <= @DateTo
				AND E.[EventActive] = 1
			ORDER BY E.[EventDate] DESC
		) AS E
		WHERE E.[EventDate] < @DateFrom OR E.[EventDate] IS NULL;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE OldEventData';

		SELECT @CurMonth = [Common].[PeriodCurrent](2);

		INSERT INTO @CurPay
		SELECT
			RN,
			ClientID,
			ClientFullName,
			ServiceName,
			PayType,
			ContractPay,
			PayDate,
			PAY,
			PRC,
			LAST_PAY,
			PAY_DATES,
			PAY_DELTA,
			PAY_ERROR,
			DistrStr,
			PAY_DATE_ERROR,
			LAST_MON,
			LAST_ACT
		FROM [dbo].[ServicePay@Report]
		(
			NULL,
			NULL,
			@CurMonth,
			NULL,
			NULL,
			1,
			0,
			0
		);

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO @CurPay';

		UPDATE C SET
			[LastPay] = P.[PAY]
		FROM @Clients AS C
		INNER JOIN @CurPay P ON P.[ClientID] = C.[Client_Id];

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE LastPayData';
/*
Вопросы:
1. Олайн-активность - количество недель с активностью
2. Статистика оффлайнов - количество недель со входами в комплект
3. Старая история посещений - параметры
4.
*/

		SELECT
			RN = ROW_NUMBER() OVER(PARTITION BY ManagerName, ServiceName ORDER BY ManagerName, ServiceName, ClientFullName),
			CC.[ClientID],
			CC.[ClientFullName],
			ST.[ServiceTypeShortName],
			CC.[ServiceName],
			CC.[ManagerName],
			D.[Distrs],
			C.[Complect],
			C.[DutyCount],
			C.[DutyQuestionCount],
			C.[DutyHotlineCount],
			C.[RivalCount],
			C.[StudyCount],
			C.[SeminarCount],
			C.[UpdatesCount],
			C.[LostCount],
			C.[DownloadCount],
			C.[DownloadBases],
			C.[OnlineActivityCount],
			C.[OfflineEnterCount],
			C.[OldRes],
			C.[OldConsExe],
			C.[ComplianceIB],
			C.[DeliveryCount],
			C.[OldEvent],
			C.[LastPay]
		FROM @Clients					AS C
		INNER JOIN dbo.ClientView		AS CC WITH(NOEXPAND) ON CC.[ClientID] = C.[Client_Id]
		INNER JOIN dbo.ServiceTypeTable AS ST ON ST.[ServiceTypeID] = CC.[ServiceTypeID]
		OUTER APPLY
		(
			SELECT
				[Distrs] = String_Agg(D.[DistrStr] + ' (' + D.[DistrTypeName] + ')', ',')
			FROM [dbo].[ClientDistrView] AS D WITH(NOEXPAND)
			WHERE D.[ID_CLIENT] = C.[Client_Id]
				AND D.[DS_REG] = 0
		) AS D
		ORDER BY ManagerName, ServiceName, ClientFullName;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RISK_REPORT2] TO rl_risk;
GO
