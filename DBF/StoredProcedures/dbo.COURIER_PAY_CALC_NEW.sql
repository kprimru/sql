USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[COURIER_PAY_CALC_NEW]
	@COUR_LIST	VARCHAR(MAX),
	@PERIOD		SMALLINT
WITH RECOMPILE
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

		IF OBJECT_ID('tempdb..#salary') IS NOT NULL
			DROP TABLE #salary

		CREATE TABLE #salary
			(
				ID INT IDENTITY(1, 1),
				COUR_NAME VARCHAR(100),
				COUR_BASE VARCHAR(100), -- базовый город для резидента
				TO_ID INT,
				CL_ID INT,
				CL_PSEDO VARCHAR(150),
				CL_BASE VARCHAR(100), -- базовый город для ТО
				CLT_ID SMALLINT,
				CLT_NAME VARCHAR(100),
				-- кол-во систем
				SYS_COUNT SMALLINT,
				-- общая сумма клиента
				CL_SUM MONEY,
				-- кол-во ТО
				TO_COUNT SMALLINT,
				-- ст-ть одной ТО, или общая стоимость
				PRICE MONEY,
				--итоговая стоимость (которую можно поднять до минималки)
				TOTAL_PRICE MONEY,
				-- минимальная сумма
				COUR_MIN MONEY,
				COUR_MAX MONEY,
				-- процент
				COUR_PERCENT DECIMAL(8, 4),
				-- КОб
				COEF DECIMAL(8, 4),
				-- оплатил ли или нет
				CL_PAY SMALLINT,
				CL_ACT SMALLINT,
				KGS SMALLINT,
				TOTAL MONEY
			)

		INSERT INTO #salary(COUR_NAME, COUR_BASE, TO_ID, CL_ID, CL_PSEDO, CL_BASE, CLT_ID, CLT_NAME, SYS_COUNT)
			SELECT
				COUR_NAME, b.CT_NAME, TO_ID, CL_ID, CL_PSEDO + ' ' + a.CT_NAME, c.CT_NAME, CLT_ID, CLT_NAME, COUNT(*)
			FROM
				dbo.CourierTable INNER JOIN
				dbo.GET_TABLE_FROM_LIST(@COUR_LIST, ',') ON Item = COUR_ID INNER JOIN
				dbo.TOTable x ON TO_ID_COUR = COUR_ID INNER JOIN
				dbo.TOAddressTable ON TA_ID_TO = TO_ID INNER JOIN
				dbo.StreetTable ON ST_ID = TA_ID_STREET INNER JOIN
				dbo.CityTable a ON a.CT_ID = ST_ID_CITY INNER JOIN
				dbo.ClientTable ON CL_ID = TO_ID_CLIENT INNER JOIN
				dbo.ClientTypeTable ON CLT_ID = CL_ID_TYPE INNER JOIN
				dbo.TODistrTable oN TD_ID_TO = TO_ID INNER JOIN
				--DIstrVIew ON DIS_ID = TD_ID_DISTR INNER JOIN
				dbo.ClientDistrView ON DIS_ID = TD_ID_DISTR INNER JOIN
				dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
							AND DIS_NUM = REG_DISTR_NUM
							AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
				dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS LEFT OUTER JOIN
				dbo.CityTable b ON b.CT_ID = COUR_ID_CITY LEFT OUTER JOIN
				dbo.CityTable c ON c.CT_ID = a.CT_ID_BASE
			WHERE (DSS_REPORT = 1 OR DS_REG = 0) AND REG_ID_PERIOD = @PERIOD
			GROUP BY COUR_NAME, TO_ID, CL_ID, CL_PSEDO, a.CT_NAME, CLT_ID, CLT_NAME, b.CT_NAME, c.CT_NAME

		DECLARE TP CURSOR LOCAL FOR
			SELECT DISTINCT CLT_ID
			FROM #salary

		OPEN TP

		DECLARE @TP SMALLINT

		DECLARE @PERCENT DECIMAL(8, 4)
		DECLARE @MIN MONEY
		DECLARE @MAX MONEY
		DECLARE @SOURCE TINYINT
		DECLARE @PAY BIT
		DECLARE @COEF BIT

		DECLARE @PR_BEGIN SMALLDATETIME
		DECLARE @PR_END SMALLDATETIME

		SELECT @PR_BEGIN = PR_DATE, @PR_END = PR_END_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PERIOD

		DECLARE @COEF_VALUE DECIMAL(8, 4)

		FETCH NEXT FROM TP INTO @TP

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT
				@PERCENT = CPS_PERCENT,
				@MIN = CPS_MIN,
				@MAX = CPS_MAX,
				@SOURCE = CPS_SOURCE,
				@PAY = CPS_PAY,
				@COEF = CPS_COEF
			FROM dbo.CourierPaySettingsTable
			WHERE CPS_ID_TYPE = @TP

			-- расчет по всем дистрибутивам ТО (по счету)
			IF @SOURCE = 1
			BEGIN
				UPDATE t
				SET t.PRICE =
					(
						SELECT SUM(BD_PRICE)
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
							dbo.BillDistrTable ON BD_ID_DISTR = DIS_ID INNER JOIN
							dbo.BillTable ON BL_ID = BD_ID_BILL
						WHERE TOTable.TO_ID = t.TO_ID
							AND BL_ID_PERIOD = @PERIOD
							AND BL_ID_CLIENT = TO_ID_CLIENT
							--AND DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
					),
					CL_ACT = 1
				FROM #salary t
				WHERE CLT_ID = @TP
			END
			-- расчет по всем дистрибутивам ТО (если есть по актам, если нет - то по счету)
			ELSE IF @SOURCE = 4
			BEGIN
				UPDATE t
				SET t.PRICE =
					(
						SELECT SUM(AD_PRICE)
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
							dbo.ActDistrTable ON AD_ID_DISTR = DIS_ID INNER JOIN
							dbo.ActTable ON ACT_ID = AD_ID_ACT
						WHERE TOTable.TO_ID = t.TO_ID
							AND ACT_DATE = (SELECT TOP 1 ACT_DATE FROM dbo.ActTable INNER JOIN dbo.ActDistrTable ON AD_ID_ACT = ACT_ID WHERE ACT_ID_CLIENT = TO_ID_CLIENT AND AD_ID_PERIOD = @PERIOD)
							AND ACT_ID_CLIENT = TO_ID_CLIENT
							--AND DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
					)
				FROM #salary t
				WHERE CLT_ID = @TP

				UPDATE t
				SET t.PRICE =
					(
						SELECT SUM(BD_PRICE)
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
							dbo.BillDistrTable ON BD_ID_DISTR = DIS_ID INNER JOIN
							dbo.BillTable ON BL_ID = BD_ID_BILL
						WHERE TOTable.TO_ID = t.TO_ID
							AND BL_ID_PERIOD = @PERIOD
							AND BL_ID_CLIENT = TO_ID_CLIENT
							--AND DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
					)
				FROM #salary t
				WHERE CLT_ID = @TP
					AND PRICE IS NULL

				UPDATE t
				SET CL_ACT = 1
				FROM #salary t
				WHERE CLT_ID = @TP
					AND EXISTS
						(
							SELECT *
							FROM
								dbo.TOTable INNER JOIN
								dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
								dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
								dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
								dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
								dbo.ActDistrTable ON AD_ID_DISTR = DIS_ID INNER JOIN
								dbo.ActTable ON ACT_ID = AD_ID_ACT
							WHERE TOTable.TO_ID = t.TO_ID
								AND ACT_DATE BETWEEN @PR_BEGIN AND @PR_END
								AND ACT_ID_CLIENT = TO_ID_CLIENT
								--AND DS_REG = 0
								AND REG_ID_PERIOD = @PERIOD
						)
			END
			-- делим общую сумму клиента на все ТО
			ELSE IF @SOURCE = 5
			BEGIN
				UPDATE t
				SET t.CL_SUM =
					(
						SELECT SUM(AD_PRICE)
						FROM
							dbo.ClientDistrTable INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
							dbo.ActDistrTable ON AD_ID_DISTR = DIS_ID INNER JOIN
							dbo.ActTable ON ACT_ID = AD_ID_ACT
						WHERE CD_ID_CLIENT = CL_ID
							AND ACT_DATE BETWEEN @PR_BEGIN AND @PR_END
							AND ACT_ID_CLIENT = CL_ID
							--AND DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
					),
					TO_COUNT =
					(
						SELECT COUNT(DISTINCT TO_ID)
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
						WHERE DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
							AND TO_ID_CLIENT = t.CL_ID
					)
				FROM #salary t
				WHERE CLT_ID = @TP

				UPDATE t
				SET t.CL_SUM =
					(
						SELECT SUM(BD_PRICE)
						FROM
							dbo.ClientDIstrTable INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
							dbo.BillDistrTable ON BD_ID_DISTR = DIS_ID INNER JOIN
							dbo.BillTable ON BL_ID = BD_ID_BILL
						WHERE CL_ID = CD_ID_CLIENT
							AND BL_ID_PERIOD = @PERIOD
							AND BL_ID_CLIENT = CL_ID
							--AND DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
					)
				FROM #salary t
				WHERE CLT_ID = @TP
					AND CL_SUM IS NULL

				UPDATE #salary
				SET PRICE = CL_SUM / TO_COUNT
				WHERE CLT_ID = @TP

				UPDATE t
				SET CL_ACT = 1
				FROM #salary t
				WHERE CLT_ID = @TP
					AND EXISTS
						(
							SELECT *
							FROM
								dbo.ClientDistrTable INNER JOIN
								dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
								dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
								dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
								dbo.ActDistrTable ON AD_ID_DISTR = DIS_ID INNER JOIN
								dbo.ActTable ON ACT_ID = AD_ID_ACT
							WHERE CD_ID_CLIENT = CL_ID
								AND AD_ID_PERIOD = @PERIOD
								AND ACT_ID_CLIENT = CL_ID
								--AND DS_REG = 0
								AND REG_ID_PERIOD = @PERIOD
						)
			END
			-- фиксированная минимальная сумма
			ELSE IF @SOURCE = 2
			BEGIN
				UPDATE #salary
				SET PRICE = @MIN,
					CL_ACT = 1
				WHERE CLT_ID = @TP
			END
			-- тоже делим всю сумму на количество, но тут зависит от оплаты
			ELSE IF @SOURCE = 3
			BEGIN
				UPDATE t
				SET CL_SUM =
					(
						SELECT SUM(BD_PRICE)
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS INNER JOIN
							dbo.BillDistrTable ON BD_ID_DISTR = DIS_ID INNER JOIN
							dbo.BillTable ON BL_ID = BD_ID_BILL
						WHERE TOTable.TO_ID_CLIENT = t.CL_ID
							AND BL_ID_PERIOD = @PERIOD
							AND BL_ID_CLIENT = TO_ID_CLIENT
							--AND DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
					),
					TO_COUNT =
					(
						SELECT COUNT(DISTINCT TO_ID)
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.PeriodRegExceptView ON REG_ID_SYSTEM = SYS_ID
										AND DIS_NUM = REG_DISTR_NUM
										AND DIS_COMP_NUM = REG_COMP_NUM INNER JOIN
							dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
						WHERE DS_REG = 0
							AND REG_ID_PERIOD = @PERIOD
							AND TO_ID_CLIENT = t.CL_ID
					),
					CL_ACT = 1
				FROM #salary t
				WHERE CLT_ID = @TP

				UPDATE #salary
				SET PRICE = CL_SUM / CASE TO_COUNT WHEN 0 THEN 1 ELSE TO_COUNT END
				WHERE CLT_ID = @TP


				UPDATE t
				SET TOTAL = @MIN
				FROM #salary t
				WHERE PRICE IS NULL AND CLT_ID = @TP
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.TOTable INNER JOIN
								dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
								dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
								dbo.BillDistrTable ON BD_ID_DISTR = DIS_ID INNER JOIN
								dbo.BillTable ON BL_ID = BD_ID_BILL
							WHERE TOTable.TO_ID_CLIENT = t.CL_ID
								--AND BL_ID_PERIOD = @PERIOD
								AND BL_ID_CLIENT = TO_ID_CLIENT
						)


			END

			UPDATE #salary
			SET COUR_MIN = @MIN,
				COUR_PERCENT = @PERCENT
			WHERE CLT_ID = @TP

			IF @PAY = 1
			BEGIN
				UPDATE #salary
				SET CL_PAY = 0
				WHERE CLT_ID = @TP

				UPDATE t
				SET CL_PAY = 1
				FROM #salary t
				WHERE NOT EXISTS
					(
						SELECT *
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.BillRestView ON BD_ID_DISTR = DIS_ID AND BL_ID_CLIENT = TO_ID_CLIENT
						WHERE TOTable.TO_ID = t.TO_ID
							AND BL_ID_PERIOD = @PERIOD
							AND BD_REST > 0
					)
					AND CLT_ID = @TP

				UPDATE t
				SET CL_PAY = 1
				FROM #salary t
				WHERE NOT EXISTS
					(
						SELECT *
						FROM
							dbo.TOTable INNER JOIN
							dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
							dbo.BillRestView ON BD_ID_DISTR = DIS_ID AND BL_ID_CLIENT = TO_ID_CLIENT
						WHERE TOTable.TO_ID = t.TO_ID
							AND BL_ID_PERIOD IN
								(
									SELECT AD_ID_PERIOD
									FROM
										dbo.ActTable INNER JOIN
										dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
									WHERE ACT_ID_CLIENT = CL_ID AND ACT_DATE BETWEEN @PR_BEGIN AND @PR_END
								)
							AND BD_REST > 0
					) AND EXISTS
					(
						SELECT *
						FROM
							dbo.ActTable INNER JOIN
							dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
						WHERE ACT_ID_CLIENT = CL_ID AND ACT_DATE BETWEEN @PR_BEGIN AND @PR_END
					)
					AND CLT_ID = @TP
			END

			IF @COEF = 1
			BEGIN
				UPDATE #salary
				SET COEF = dbo.PayCoefGet(SYS_COUNT)
				WHERE CLT_ID = @TP
			END

			UPDATE #salary
			SET TOTAL = PRICE * ISNULL(COUR_PERCENT, 100) / 100
			WHERE CLT_ID = @TP
				AND TOTAL IS NULL

			UPDATE #salary
			SET TOTAL_PRICE = TOTAL
			WHERE CLT_ID = @TP
				AND TOTAL_PRICE IS NULL

			IF @MAX IS NOT NULL
			BEGIN
				UPDATE #salary
				SET TOTAL = PRICE * ISNULL(COUR_PERCENT, 100) / 100,
					COEF = 1,
					COUR_MAX = @MAX
				WHERE CLT_ID = @TP
					AND PRICE * ISNULL(COUR_PERCENT, 100) / 100 >= @MAX
			END

			IF @MIN IS NOT NULL
			BEGIN
				UPDATE #salary
				SET TOTAL = @MIN
				WHERE CLT_ID = @TP
					AND TOTAL < @MIN
			END

			FETCH NEXT FROM TP INTO @TP
		END

		CLOSE TP
		DEALLOCATE TP

		UPDATE t
		SET KGS = 100 *
			(
				SELECT COUNT(*)
				FROM #salary b
				WHERE b.COUR_NAME = t.COUR_NAME
					AND b.CL_BASE = t.CL_BASE
					AND CLT_NAME LIKE '%КГС%'
			) /
			(
				SELECT COUNT(*)
				FROM #salary a
				WHERE a.COUR_NAME = t.COUR_NAME
					AND a.CL_BASE = t.CL_BASE
			)
		FROM #salary t
		WHERE (
				SELECT COUNT(*)
				FROM #salary a
				WHERE a.COUR_NAME = t.COUR_NAME
					AND a.CL_BASE = t.CL_BASE
			) <> 0



		UPDATE #salary
		SET KGS = (SELECT TOP 1 KGS FROM #salary WHERE KGS IS NOT NULL)
		WHERE KGS IS NULL

		UPDATE #salary
		SET COUR_MIN = NULL
		WHERE KGS < 70 AND CLT_NAME = 'КГС корп.'

		SELECT
			ID, COUR_NAME, COUR_BASE,
			TO_ID, CL_ID, CL_PSEDO, CL_BASE,
			CLT_ID, CLT_NAME, SYS_COUNT,
			CL_SUM, TO_COUNT, PRICE, TOTAL_PRICE,
			COUR_MIN, COUR_MAX, COUR_PERCENT, COEF,
			CL_PAY, CL_ACT, KGS, TOTAL,
			(
				SELECT COUNT(DISTINCT CL_BASE)
				FROM #salary b
				WHERE a.COUR_NAME = b.COUR_NAME
			) AS COUR_COUNT,
			CASE
				WHEN CL_BASE = COUR_BASE THEN 'БГ'
				WHEN CL_BASE <> COUR_BASE THEN 'УТ'
				ELSE '-'
			END AS CL_TERR
		FROM #salary a
		ORDER BY COUR_NAME, CL_BASE, CL_PSEDO

		IF OBJECT_ID('tempdb..#salary') IS NOT NULL
			DROP TABLE #salary

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
