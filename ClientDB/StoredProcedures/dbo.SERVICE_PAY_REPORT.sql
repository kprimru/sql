USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_PAY_REPORT]
	@MANAGER		INT,
	@SERVICE		INT,
	@MONTH			UNIQUEIDENTIFIER,
	@CL_COUNT		INT = NULL OUTPUT,
	@PAY_COUNT		INT = NULL OUTPUT,
	@PAY_TOTAL		INT = NULL OUTPUT,
	@PAY_PERCENT	DECIMAL(8, 2) = NULL OUTPUT,
	@BEGIN			SMALLDATETIME = NULL,
	@END			SMALLDATETIME = NULL,
	@SORT			TINYINT = NULL,
	@DAY			BIT = 0,
	@HIDE			BIT = 0
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

		DECLARE @MON_DATE SMALLDATETIME

		SELECT @MON_DATE = START FROM Common.Period WHERE ID = @MONTH

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF @SERVICE IS NULL AND @MANAGER IS NULL
			SET @MANAGER = 0

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID		INT,
				ClientFullName	VARCHAR(500),
				ServiceName		VARCHAR(150),
				PayType			VARCHAR(150),
				ContractPay		VARCHAR(150),
				PayDate			SMALLDATETIME,
				PayMonth		SMALLDATETIME
			)

		INSERT INTO #client(ClientID, ClientFullName, ServiceName, PayType, ContractPay, PayDate, PayMonth)
			SELECT
				ClientID, ClientFullName, ServiceName, CASE WHEN a.ID_HEAD IS NULL THEN PayTypeName ELSE 'не оплачивает' END, ContractPayName,
				DATEADD(MONTH, CASE WHEN ContractPayDay > DATEPART(DAY, GETDATE()) THEN -1 ELSE 0 END,
					DATEADD(DAY,
						CASE
							WHEN DATEPART(MONTH, @MON_DATE) = 2 AND DATEPART(YEAR, @MON_DATE) % 4 = 0 AND ContractPayDay > 29 THEN 29
							WHEN DATEPART(MONTH, @MON_DATE) = 2 AND DATEPART(YEAR, @MON_DATE) % 4 <> 0 AND ContractPayDay > 28 THEN 28
							WHEN DATEPART(MONTH, @MON_DATE) IN (4, 6, 11) AND DATEPART(YEAR, @MON_DATE) % 4 <> 0 AND ContractPayDay > 30 THEN 30
							ELSE ContractPayDay - 1
						END, DATEADD(MONTH, PayTypeMonth, @MON_DATE))),
				CASE @DAY
					WHEN 1 THEN DATEADD(MONTH, CASE WHEN ContractPayDay > DATEPART(DAY, GETDATE()) THEN -1 ELSE 0 END, DATEADD(MONTH, PayTypeMonth, @MON_DATE))
					ELSE DATEADD(MONTH, PayTypeMonth, @MON_DATE)
				END

			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.ServiceTable ON ClientServiceID = ServiceID
				INNER JOIN dbo.PayTypeTable b ON a.PayTypeID = b.PayTypeID
				OUTER APPLY dbo.ClientContractPayGet(a.ClientID, NULL) AS o_O
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND STATUS = 1 --AND ID_HEAD IS NULL

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				CL_ID		INT,
				DisStr		VARCHAR(50),
				SYS_REG		VARCHAR(20),
				SYS_ORD		INT,
				DISTR		INT,
				COMP		TINYINT,
				BILL		MONEY,
				INCOME		MONEY,
				LAST_PAY	SMALLDATETIME,
				LAST_ACT	SMALLDATETIME,
				MON_DATE	SMALLDATETIME,
				BILL_DATE	SMALLDATETIME
			)

		INSERT INTO #distr(CL_ID, DisStr, SYS_REG, SYS_ORD, DISTR, COMP/*, LAST_PAY, BILL, INCOME*/)
			SELECT ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP
			FROM
				#client
				INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON ClientID = ID_CLIENT
			WHERE (DS_REG = 0 OR @BEGIN IS NOT NULL OR @END IS NOT NULL)

			UNION

			SELECT a.ClientID, DistrStr, SystemBaseName, SystemOrder, DISTR, COMP
			FROM
				#client a
				INNER JOIN dbo.ClientTable b ON a.ClientID = b.ID_HEAD
				INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON b.ClientID = ID_CLIENT
			WHERE (DS_REG = 0 OR @BEGIN IS NOT NULL OR @END IS NOT NULL) AND b.STATUS = 1

		IF @BEGIN IS NOT NULL OR @END IS NOT NULL
		BEGIN
			DELETE
			FROM #distr
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.DBFIncomeDateView
					WHERE SYS_REG_NAME = SYS_REG
						AND DIS_NUM = DISTR
						AND DIS_COMP_NUM = COMP
						AND (IN_DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (IN_DATE <= @END OR @END IS NULL)
				)

			/*
			UPDATE #distr
			SET MON_DATE =
				(
					SELECT MAX(PR_DATE)
					FROM dbo.DBFIncomeDateView
					WHERE SYS_REG_NAME = SYS_REG
						AND DIS_NUM = DISTR
						AND DIS_COMP_NUM = COMP
				)
			*/
		END
		--ELSE

		UPDATE #distr
		SET MON_DATE = (SELECT PayMonth FROM #client WHERE ClientID = CL_ID)

		UPDATE #distr
		SET BILL =
			(
				SELECT BD_TOTAL_PRICE
				FROM dbo.DBFBillView
				WHERE PR_DATE = MON_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
			),
			INCOME =
			(
				SELECT ID_PRICE
				FROM dbo.DBFIncomeView
				WHERE PR_DATE = MON_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
			),
			LAST_PAY =
			(
				SELECT MAX(PR_DATE)
				FROM dbo.DBFBillRestView
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					/*AND PR_DATE <= MON_DATE*/ AND BD_REST = 0
			),
			LAST_ACT =
			(
				SELECT MAX(PR_DATE)
				FROM dbo.DBFActView
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					AND PR_DATE <= @MON_DATE
			),
			BILL_DATE =
			(
				SELECT MAX(PR_DATE)
				FROM dbo.DBFBillView
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					AND PR_DATE = @MON_DATE
			)

		IF OBJECT_ID('tempdb..#distr_date') IS NOT NULL
			DROP TABLE #distr_date

		CREATE TABLE #distr_date
			(
				CL_ID	INT,
				DisStr	VARCHAR(50),
				DATE	SMALLDATETIME
			)

		IF @BEGIN IS NOT NULL OR @END IS NOT NULL
			INSERT INTO #distr_date(CL_ID, DisStr, DATE)
				SELECT CL_ID, DisStr, IN_DATE
				FROM
					#distr
					INNER JOIN dbo.DBFIncomeDateView ON /*PR_DATE = MON_DATE AND */SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
				WHERE (IN_DATE >= @BEGIN OR @BEGIN IS NULL)
					AND (IN_DATE <= @END OR @END IS NULL)
		ELSE
			INSERT INTO #distr_date(CL_ID, DisStr, DATE)
				SELECT CL_ID, DisStr, IN_DATE
				FROM
					#distr
					INNER JOIN dbo.DBFIncomeDateView ON PR_DATE = MON_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ClientID		INT,
				ClientFullName	VARCHAR(500),
				ServiceName		VARCHAR(150),
				PayType			VARCHAR(150),
				ContractPay		VARCHAR(150),
				PayDate			SMALLDATETIME,
				PAY				VARCHAR(50),
				PRC				DECIMAL(8, 4),
				LAST_PAY		SMALLDATETIME,
				PAY_DATES		VARCHAR(MAX),
				PAY_DELTA		INT,
				LAST_MON		SMALLDATETIME,
				SYS_ORD			INT,
				DIS_NUM			INT,
				LAST_ACT		SMALLDATETIME
			)

		IF @BEGIN IS NOT NULL OR @END IS NOT NULL
			DELETE FROM #client
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #distr
					WHERE CL_ID = ClientID
				)

		INSERT INTO #result(ClientID, ClientFullName, ServiceName, PayType, ContractPay, PayDate, PAY, PRC, LAST_PAY, PAY_DATES, PAY_DELTA, LAST_MON, SYS_ORD, DIS_NUM, LAST_ACT)
			SELECT
				ClientID, ClientFullName, ServiceName, PayType, ContractPay, PayDate,
				CASE
					WHEN BILL IS NULL THEN 'НЕТ СЧЕТА (' + CONVERT(VARCHAR(20), PayMonth, 104) + ')'
					WHEN BILL = INCOME THEN 'Да'
					ELSE 'Нет'
				END AS PAY,
				ROUND(100 * (BILL - ISNULL(INCOME, 0)) / BILL, 2) AS PRC,
				LAST_PAY, PAY_DATES,
				DATEDIFF(DAY, PayDate, LAST_PAY) AS PAY_DELTA,
				(
					SELECT MIN(LAST_PAY)
					FROM #distr
					WHERE ClientID = CL_ID
						AND BILL_DATE IS NOT NULL
				), SystemOrder, DISTR,
				(
					SELECT MIN(LAST_ACT)
					FROM #distr
					WHERE ClientID = CL_ID
						AND BILL_DATE IS NOT NULL
				)
			FROM
				#client
				LEFT OUTER JOIN
					(
						SELECT
							CL_ID, SUM(BILL) AS BILL, SUM(INCOME) AS INCOME,
							(
								SELECT MAX(DATE)
								FROM #distr_date y
								WHERE z.CL_ID = y.CL_ID
							) AS LAST_PAY,
							REVERSE(STUFF(REVERSE((
								SELECT CONVERT(VARCHAR(20), DATE, 104) + ', '
								FROM
									(
										SELECT DISTINCT DATE
										FROM #distr_date y
										WHERE z.CL_ID = y.CL_ID
									) AS o_O
								ORDER BY DATE DESC FOR XML PATH('')
							)), 1, 2, '')) AS PAY_DATES
						FROM #distr z
						GROUP BY CL_ID
					) AS o_O ON CL_ID = ClientID
				CROSS APPLY
					(
						SELECT TOP 1 HostOrder AS SystemOrder, DISTR
						FROM
							dbo.ClientDistrView z WITH(NOEXPAND)
							INNER JOIN dbo.Hosts y ON z.HostID = y.HostID
						WHERE z.ID_CLIENT = ClientID AND DS_REG = 0
						ORDER BY HostOrder, DISTR
					) AS t
			ORDER BY ClientFullName


		--тут итоги собрать в текст

		SELECT @CL_COUNT = COUNT(*)
		FROM #client

		SELECT @PAY_COUNT = COUNT(*)
		FROM #client
		WHERE PayType NOT IN ('не оплачивает', 'бесплатно РДД')

		SELECT @PAY_TOTAL = COUNT(*)
		FROM #result
		WHERE PAY = 'Да' AND PayType NOT IN ('не оплачивает', 'бесплатно РДД')

		IF @PAY_COUNT = 0
			SET @PAY_PERCENT = 0
		ELSE
			SET @PAY_PERCENT = ROUND(100 * CONVERT(FLOAT, @PAY_TOTAL) / @PAY_COUNT, 0)

		SELECT
			ROW_NUMBER() OVER(PARTITION BY ServiceName ORDER BY CASE
				WHEN @SORT = 0 THEN ClientFullName
				WHEN @SORT = 1 THEN NULL
				ELSE ClientFullName
			END,
			CASE
				WHEN @SORT = 0 THEN NULL
				WHEN @SORT = 1 THEN SYS_ORD
				ELSE NULL
			END,
			CASE
				WHEN @SORT = 0 THEN NULL
				WHEN @SORT = 1 THEN DIS_NUM
				ELSE NULL
			END,
			ClientFullName) AS RN,
			ClientID, ClientFullName, ServiceName, PayType, ContractPay, PayDate, PAY, PRC, LAST_PAY, PAY_DATES, PAY_DELTA,
			CASE
				WHEN PayType IN ('не оплачивает', 'бесплатно РДД') THEN 2
				ELSE
					CASE PAY 
						WHEN 'Да' THEN 1
						ELSE 0
					END
			END AS PAY_ERROR,
			(
				SELECT TOP 1 DistrStr + ' (' + DistrTypeName + ')'
				FROM dbo.ClientDistrView WITH(NOEXPAND)
				WHERE ID_CLIENT = ClientID AND DS_REG = 0
				ORDER BY SystemOrder
			) AS DistrStr,
			/*CASE
				WHEN PAY_DELTA <= 0 THEN 1
				ELSE 0
			END*/0 AS PAY_DATE_ERROR,
			LAST_MON, LAST_ACT--, SYS_ORD, DIS_NUM
		FROM #result
		WHERE @HIDE = 0 OR @HIDE = 1 AND PayType NOT IN ('не оплачивает', 'бесплатно РДД')
		ORDER BY
			ServiceName,
			CASE
				WHEN @SORT = 0 THEN ClientFullName
				WHEN @SORT = 1 THEN NULL
				ELSE ClientFullName
			END,
			CASE
				WHEN @SORT = 0 THEN NULL
				WHEN @SORT = 1 THEN SYS_ORD
				ELSE NULL
			END,
			CASE
				WHEN @SORT = 0 THEN NULL
				WHEN @SORT = 1 THEN DIS_NUM
				ELSE NULL
			END,
			ClientFullName

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#distr_date') IS NOT NULL
			DROP TABLE #distr_date

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_PAY_REPORT] TO rl_service_pay;
GO
