USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_MONTH_REPORT_XL2]
	@BEGIN1		SmallDateTime 	= NULL,
	@END1		SmallDateTime 	= NULL,
	@BEGIN2		SmallDateTime 	= NULL,
	@END2		SmallDateTime 	= NULL,
	@BEGIN3		SmallDateTime 	= NULL,
	@END3		SmallDateTime 	= NULL,
	@BEGIN4		SmallDateTime 	= NULL,
	@END4		SmallDateTime 	= NULL,
	@BEGIN5		SmallDateTime 	= NULL,
	@END5		SmallDateTime 	= NULL,
	@WEEKK		Int				= NULL,
	@DATE		VarChar(20)		= NULL,
	@INET		Bit 			= NULL,
	@MANAGER	SmallInt		= NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@WEEK_CNT		SmallInt,
		@HST			SmallInt,
		@MINDATE 		SmallDateTime,
		@MAXDATE 		SmallDateTime;

	DECLARE @WEEK TABLE
	(
		WEEK_ID			TinyInt				IDENTITY(1, 1),
		WBEGIN			SmallDateTime,
		WEND			SmallDateTime,
		PRIMARY KEY CLUSTERED(WEEK_ID)
	);

	DECLARE @month Table
	(
		UD_ID_CLIENT	Int,
		UD_ID			Int,
		UI_ID_BASE		SmallInt,
		UI_DISTR		Int,
		UI_COMP			TinyInt,
		UIU_DATE_S		SmallDateTime,
		PRIMARY KEY CLUSTERED(UD_ID_CLIENT, UIU_DATE_S, UI_ID_BASE, UI_DISTR, UI_COMP, UD_ID)
	);

	DECLARE @client Table
	(
		CL_ID			Int,
		IsOnline		Bit,
		PRIMARY KEY CLUSTERED(CL_ID)
	);

	DECLARE @system Table
	(
		ClientID		Int,
		SystemID		SmallInt,
		InfoBankID		SmallInt,
		DistrNumber		Int,
		CompNumber		TinyInt
		PRIMARY KEY CLUSTERED(ClientID, SystemID, InfoBankID, DistrNumber, CompNumber)
	);

	DECLARE @InetUser Table
	(
		UD_ID			Int,
		UF_PATH			TinyInt,
		UF_DATE_S		SmallDateTime,
		UF_KIND			VarChar(20)
	);

	DECLARE @week_system Table
	(
		CL_ID			Int,
		WEEK_ID			TinyInt,
		CNT				Int
		PRIMARY KEY CLUSTERED(CL_ID, WEEK_ID)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @DATE IS NULL
			SET @DATE = CONVERT(VARCHAR(20), GETDATE(), 112)

		IF @INET IS NULL
			SET @INET = 0

		-- всегда смотрим по факту
		SET @INET = 0

		INSERT INTO @WEEK
			SELECT @BEGIN1, @END1

		INSERT INTO @WEEK
			SELECT @BEGIN2, @END2

		INSERT INTO @WEEK
			SELECT @BEGIN3, @END3

		INSERT INTO @WEEK
			SELECT @BEGIN4, @END4

		INSERT INTO @WEEK
			SELECT @BEGIN5, @END5

		SELECT @MINDATE = MIN(WBEGIN)
		FROM @WEEK

		SELECT @MAXDATE = MAX(WEND)
		FROM @WEEK

		SELECT @HST = HostID
		FROM dbo.SystemTable
		WHERE SystemBaseName = 'LAW'


		SET @WEEK_CNT = 0

		IF @BEGIN1 IS NOT NULL
			SET @WEEK_CNT = @WEEK_CNT + 1
		IF @BEGIN2 IS NOT NULL
			SET @WEEK_CNT = @WEEK_CNT + 1
		IF @BEGIN3 IS NOT NULL
			SET @WEEK_CNT = @WEEK_CNT + 1
		IF @BEGIN4 IS NOT NULL
			SET @WEEK_CNT = @WEEK_CNT + 1
		IF @BEGIN5 IS NOT NULL
			SET @WEEK_CNT = @WEEK_CNT + 1

		INSERT INTO @client(CL_ID, IsOnline)
		SELECT C.ClientID, IsNull(O.[IsOnline], 1)
		FROM dbo.ClientView						AS C WITH(NOEXPAND)
		INNER JOIN dbo.ServiceStatusConnected() AS S ON S.ServiceStatusId = C.ServiceStatusId
		OUTER APPLY
		(
			SELECT TOP (1)
				[IsOnline] = 0
			FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
			WHERE	D.ID_CLIENT = C.ClientID
				AND D.DS_REG = 0
				AND D.DistrTypeBaseCheck = 1
				AND D.SystemBaseCheck = 1
		) AS O
		WHERE (C.ManagerID = @MANAGER OR @MANAGER IS NULL);

		INSERT INTO @system(ClientID, SystemID, InfoBankID, DistrNumber, CompNumber)
		SELECT CL_ID, D.SystemID, InfoBankID, DISTR, COMP
		FROM @client												AS C
		-- мы понимаем, что тут будет чуть больше чем 1 запись. И они будут отсортированы по CL_ID
		INNER MERGE JOIN dbo.ClientDistrView						AS D WITH(NOEXPAND) ON C.CL_ID = D.ID_CLIENT
		CROSS APPLY dbo.SystemBankGet(D.SystemID, D.DistrTypeID)	AS S
		WHERE D.DS_REG = 0
			AND S.InfoBankActive = 1;

		INSERT INTO @month(UD_ID_CLIENT, UD_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S)
		SELECT DISTINCT UD_ID_CLIENT, UD_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S
		FROM @client					AS C
		INNER JOIN USR.USRIBDateView	AS U WITH(NOEXPAND) ON U.UD_ID_CLIENT = C.CL_ID
		WHERE U.UIU_DATE_S >= @MINDATE
			AND U.UIU_DATE_S <= @MAXDATE;

		IF @INET = 1
			INSERT INTO @InetUser(UD_ID, UF_PATH, UF_DATE_S, UF_KIND)
			SELECT UD_ID, UF_PATH, UF_DATE_S, USRFileKindName
			FROM @client				AS C
			INNER JOIN USR.USRFileView	AS U WITH(NOEXPAND) ON C.CL_ID = U.UD_ID_CLIENT
			WHERE U.UF_DATE_S >= @MINDATE
				AND U.UF_DATE_S <= @MAXDATE

			UNION

			SELECT UD_ID, 0, UIU_DATE_S, USRFileKindName
			FROM @client					AS C
			INNER JOIN USR.USRIBDateView	AS U WITH(NOEXPAND) ON C.CL_ID = U.UD_ID_CLIENT
			WHERE U.UIU_DATE_S >= @MINDATE
				AND U.UIU_DATE_S <= @MAXDATE
				AND U.USRFileKindName IN ('R', 'P')



		IF @INET = 1
		BEGIN
			INSERT INTO @week_system(CL_ID, WEEK_ID, CNT)
			SELECT C.CL_ID, W.WEEK_ID, I.CNT
			FROM @week			AS W
			CROSS JOIN @client	AS C
			OUTER APPLY
			(
				SELECT [CNT] = COUNT(*)
				FROM
				(
					SELECT DISTINCT SystemID, UI_DISTR, UI_COMP
					FROM @system		AS S
					INNER JOIN @month	AS M ON UD_ID_CLIENT = S.CLientID
											AND UI_ID_BASE = S.InfoBankID
											AND UI_DISTR = DistrNumber
											AND UI_COMP = CompNumber
											AND CL_ID = S.ClientID
					WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND
						AND EXISTS
						(
							SELECT *
							FROM @InetUser AS I
							WHERE M.UD_ID = I.UD_ID
								AND UF_DATE_S BETWEEN WBEGIN AND WEND
								AND UF_PATH IN (0, 3)
								AND UF_KIND IN ('R', 'P', 'K')
						)

					UNION

					SELECT DISTINCT SystemID, UI_DISTR, UI_COMP
					FROM @system		AS S
					INNER JOIN @month	AS M ON UD_ID_CLIENT = S.CLientID
											AND UI_ID_BASE = S.InfoBankID
											AND UI_DISTR = DistrNumber
											AND UI_COMP = CompNumber
											AND CL_ID = S.ClientID
					WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND
						AND EXISTS
							(
								SELECT *
								FROM @InetUser AS I
								WHERE M.UD_ID = I.UD_ID
									AND UF_DATE_S BETWEEN WBEGIN AND WEND
									AND UF_PATH IN (1, 2)
							)
						AND EXISTS
							(
								SELECT *
								FROM @InetUser AS I
								WHERE M.UD_ID = I.UD_ID
									AND UF_DATE_S BETWEEN WBEGIN AND WEND
									AND UF_PATH = 3
							)
				) AS I
			) AS I
		END
		ELSE
		BEGIN
			INSERT INTO @week_system(CL_ID, WEEK_ID, CNT)
			SELECT CL_ID, WEEK_ID, I.CNT
			FROM @week			AS W
			CROSS JOIN @client	AS C
			OUTER APPLY
			(
				SELECT CNT = COUNT(*)
				FROM
				(
					SELECT DISTINCT SystemID, UI_DISTR, UI_COMP
					FROM @system			AS S
					-- тут лучше HASH, потому что не придется предварительно сотрировать
					INNER JOIN @month	AS M ON UD_ID_CLIENT = S.ClientID
												AND UI_ID_BASE = S.InfoBankID
												AND UI_DISTR = DistrNumber
												AND UI_COMP = CompNumber

					WHERE UIU_DATE_S BETWEEN WBEGIN AND WEND
						AND CL_ID = S.ClientID
				) AS I
			) AS I;
		END

		-- ToDo избавить от лукапов
		-- ToDo избавиться от лишних подзапросов с помощью OUTER APPLY
		SELECT
			ClientID, ServiceFullName, ManagerFullName, ClientFullName, DISTR, NET, PayTypeName, RangeValue, Category, ServicePositionName, ContractTypeName,
			/*
			CASE
				WHEN Category = 'C' AND IsOnline = 1 THEN 1.5
				ELSE 1
			END
			*
			CASE
				WHEN ContractTypeName IN ('спецовый', 'спецовый КГС', 'спецовый РДД', 'информобмен') AND ClientBaseCount > 3 THEN 1.2
				WHEN Category = 'A' AND /*ServicePositionName <> 'сервис-инженер' AND */ContractTypeName IN ('коммерческий', 'коммерческий ВИП', 'пакетное соглашение') THEN 1.4
				WHEN Category = 'B' AND /*ServicePositionName <> 'сервис-инженер' AND */ContractTypeName IN ('коммерческий', 'коммерческий ВИП', 'пакетное соглашение') THEN 1.2
				ELSE 1
			END AS COEF,
			*/
			CASE
				WHEN Category IN ('A', 'B') AND ContractTypeName IN ('спецовый', 'спецовый КГС', 'спецовый РДД', 'информобмен') THEN 1.2
				WHEN Category = 'A' AND /*ServicePositionName <> 'сервис-инженер' AND */ContractTypeName IN ('коммерческий', 'коммерческий ВИП', 'пакетное соглашение') THEN 1.5
				WHEN Category = 'B' AND /*ServicePositionName <> 'сервис-инженер' AND */ContractTypeName IN ('коммерческий', 'коммерческий ВИП', 'пакетное соглашение') THEN 1.4
				ELSE 1
			END AS COEF,
			-- количество визитов (когда было обновлено систем > 0
			--IsOnline, @WEEK_CNT, VISIT_CNT4, VISIT_CNT5,
			CASE
				WHEN IsOnline = 1 AND Category = 'C' THEN
					CASE
						WHEN @WEEK_CNT = 5 THEN 3
						ELSE 2
					END
				WHEN IsOnline = 1 AND @WEEK_CNT = 5 THEN VISIT_CNT5
				WHEN IsOnline = 1 AND @WEEK_CNT = 4 THEN VISIT_CNT4
				ELSE
					CASE
						WHEN ServicedSystemCount1 = 0 THEN 0
						ELSE 1
					END +
					CASE
						WHEN ServicedSystemCount2 = 0 THEN 0
						ELSE 1
					END +
					CASE
						WHEN ServicedSystemCount3 = 0 THEN 0
						ELSE 1
					END +
					CASE
						WHEN ServicedSystemCount4 = 0 THEN 0
						ELSE 1
					END +
					CASE
						WHEN ServicedSystemCount5 = 0 THEN 0
						ELSE 1
					END
			END AS VISIT_CNT,
			-- максимальное количество визитов (ограничить для категории C)
			IsNull(CASE
				WHEN Category = 'C' THEN
					CASE
						WHEN @WEEK_CNT = 5 THEN 3
						ELSE 2
					END
				ELSE 5
			END, 5) AS MAX_VISIT_CNT,
			--5 AS MAX_VISIT_CNT,
			ClientBaseCount, ContractPayName, ServicedSystemCount1, ServicedSystemCount2, ServicedSystemCount3, ServicedSystemCount4, ServicedSystemCount5
		FROM
		(
			SELECT
				b.ClientID, ServiceFullName, ManagerFullName, ClientFullName, PayTypeName, RangeValue,
				Category = ClientTypeName, ServicePositionName, ContractTypeName = h.Name, VISIT_CNT4, VISIT_CNT5, IsOnline,
				(
					SELECT TOP 1 DISTR
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = b.ClientID
						AND z.DS_REG = 0
						AND z.HostID = @HST
					ORDER BY DISTR
				) AS DISTR,
				(
					SELECT TOP 1 DistrTypeName
					FROM dbo.ClientDistrView z WITH(NOEXPAND)
					WHERE z.ID_CLIENT = b.ClientID
						AND z.DS_REG = 0
						AND z.HostID = @HST
					ORDER BY DISTR
				) AS NET,
				(
					SELECT Count(*)
					FROM
					(
						SELECT DISTINCT SystemID, DistrNumber, CompNumber
						FROM @system z
						WHERE z.ClientID = b.ClientID
					) AS o_O
				) AS ClientBaseCount,
				(
					SELECT TOP 1 ContractPayName
					FROM dbo.ClientContractPayGet(b.ClientID, NULL)
				) AS ContractPayName,
				(
					SELECT CNT
					FROM @week_system z
					WHERE z.CL_ID = a.CL_ID
						AND WEEK_ID = 1
			   ) AS ServicedSystemCount1,
			   (
					SELECT CNT
					FROM @week_system z
					WHERE z.CL_ID = a.CL_ID
						AND WEEK_ID = 2
			   ) AS ServicedSystemCount2,
			   (
					SELECT CNT
					FROM @week_system z
					WHERE z.CL_ID = a.CL_ID
						AND WEEK_ID = 3
			   ) AS ServicedSystemCount3,
			   (
					SELECT CNT
					FROM @week_system z
					WHERE z.CL_ID = a.CL_ID
						AND WEEK_ID = 4
			   ) AS ServicedSystemCount4,
			   (
					SELECT CNT
					FROM @week_system z
					WHERE z.CL_ID = a.CL_ID
						AND WEEK_ID = 5
			   ) AS ServicedSystemCount5
			FROM @client						AS a			INNER JOIN dbo.ClientTable			AS b ON a.CL_ID = b.ClientID			INNER JOIN dbo.RangeTable			AS c ON c.RangeID = b.RangeID
			INNER JOIN dbo.ServiceTable 		AS d ON d.ServiceID = b.ClientServiceID
			INNER JOIN dbo.ManagerTable 		AS e ON e.ManagerID = d.ManagerID
			LEFT JOIN dbo.PayTypeTable			AS f ON f.PayTypeID = b.PayTypeID
			LEFT JOIN dbo.ServicePositionTable	AS g ON d.ServicePositionID = g.ServicePositionID
			LEFT JOIN dbo.ClientKind			AS h ON b.ClientKind_Id = h.Id
			LEFT JOIN dbo.ClientTypeTable		AS i ON i.ClientTypeID = b.ClientTypeID
			LEFT JOIN dbo.ClientVisitCount		AS j ON j.ID = b.ClientVisitCountID
		) AS o_O
		ORDER BY ManagerFullName, ServiceFullName, DISTR, ClientFullName;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_MONTH_REPORT_XL2] TO rl_report_month_xl;
GO