USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[REPORT_ACT_SELECT]
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@system VARCHAR(MAX),
	@org SMALLINT = NULL
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

		IF OBJECT_ID('tempdb..#tmpsystem') IS NOT NULL
			DROP TABLE #tmpsystem

		CREATE TABLE #tmpsystem
			(
				TSYS_ID INT
			)

		IF @system IS NOT NULL
			INSERT INTO #tmpsystem
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@system, ',')
		ELSE
			INSERT INTO #tmpsystem
				SELECT SYS_ID
				FROM dbo.SystemTable
				WHERE SYS_ACTIVE = 1

		SELECT
			SL_DATE, SL_ID, SL_TP,
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			a.DIS_ID, a.DIS_STR, a.SYS_ORDER, a.SYS_NAME,
			NULL AS AD_TOTAL_PRICE,
			--ROUND((100 * ID_PRICE / (100 + TX_PERCENT)), 2) AS ID_PRICE,
			ID_PRICE - ROUND(ID_PRICE * TX_PERCENT / (100.0 + TX_PERCENT), 2) AS ID_PRICE,
			CASE
				WHEN ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + ROUND(ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) * TX_PERCENT / 100, 2) > SL_REST THEN
					ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) - 0.01
				WHEN ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + ROUND(ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) * TX_PERCENT / 100, 2) < SL_REST THEN
					ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + 0.01
				ELSE ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2)
			END AS SL_REST, NULL AS ACT_MONTH,
			SN_ID, SN_NAME, SL_BEZ_NDS
		FROM
			dbo.SaldoTable
			INNER JOIN dbo.ClientTable ON CL_ID = SL_ID_CLIENT
			INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR
			INNER JOIN dbo.IncomeDistrTable ON ID_ID = SL_ID_IN_DIS
			INNER JOIN dbo.IncomeTable ON IN_ID = ID_ID_INCOME
			CROSS APPLY
			(
				SELECT TOP 1 *
				FROM dbo.TaxTable
				WHERE TX_ID IN
					(
						SELECT AD_ID_TAX
						FROM dbo.ActDistrTable
						INNER JOIN dbo.ActTable ON ACT_ID = AD_ID_ACT
						WHERE AD_ID_DISTR = ID_ID_DISTR
							AND AD_ID_PERIOD = ID_ID_PERIOD
							AND ACT_ID_CLIENT = IN_ID_CLIENT
					)

				UNION ALL

				SELECT TOP 1 *
				FROM dbo.TaxTable
				WHERE TX_PERCENT =
					CASE
						WHEN SYS_ID_SO = 1 AND @BeginDate < '20190101' THEN 18
						WHEN SYS_ID_SO = 1 AND @BeginDate >= '20190101' THEN 20
						WHEN SYS_ID_SO = 2 THEN 10
						WHEN SYS_ID_SO = 4 THEN 0
					END
					AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ActDistrTable
						INNER JOIN dbo.ActTable ON ACT_ID = AD_ID_ACT
						WHERE AD_ID_DISTR = ID_ID_DISTR
							AND AD_ID_PERIOD = ID_ID_PERIOD
							AND ACT_ID_CLIENT = IN_ID_CLIENT
					)
			) AS T
			--INNER JOIN dbo.TaxTable ON TX_ID = AD_ID_TAX
			INNER JOIN #tmpsystem ON a.SYS_ID = TSYS_ID
			LEFT JOIN dbo.DistrFinancingTable b ON DIS_ID = DF_ID_DISTR
			LEFT JOIN dbo.SystemNetTable ON SN_ID = DF_ID_NET

		WHERE SL_DATE BETWEEN @begindate AND @enddate
			AND (IN_ID_ORG = @org OR @org IS NULL)

		UNION ALL

		SELECT
			SL_DATE, SL_ID, SL_TP,
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			a.DIS_ID, a.DIS_STR, a.SYS_ORDER, a.SYS_NAME,
			AD_PRICE AS AD_TOTAL_PRICE, NULL,
			CASE
				WHEN ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + ROUND(ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) * TX_PERCENT / 100, 2) > SL_REST THEN
					ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) - 0.01
				WHEN ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + ROUND(ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) * TX_PERCENT / 100, 2) < SL_REST THEN
					ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + 0.01
				ELSE ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2)
			END AS SL_REST,
			c.PR_DATE AS ACT_MONTH,
			SN_ID, SN_NAME, SL_BEZ_NDS
		FROM
			dbo.SaldoTable
			INNER JOIN dbo.ClientTable ON CL_ID = SL_ID_CLIENT
			INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR
			INNER JOIN dbo.ActDistrTable ON AD_ID = SL_ID_ACT_DIS
			INNER JOIN dbo.ActTable ON ACT_ID = AD_ID_ACT
			INNER JOIN dbo.TaxTable ON TX_ID = AD_ID_TAX
			INNER JOIN dbo.PeriodTable c ON PR_ID = AD_ID_PERIOD
			INNER JOIN #tmpsystem ON a.SYS_ID = TSYS_ID
			LEFT JOIN dbo.DistrFinancingTable b ON DF_ID_DISTR = DIS_ID
			LEFT JOIN dbo.SystemNetTable ON SN_ID = DF_ID_NET
		WHERE SL_DATE BETWEEN @begindate AND @enddate
			AND (ACT_ID_ORG = @org OR @org IS NULL)

		UNION ALL

		SELECT
			SL_DATE, SL_ID, SL_TP,
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			a.DIS_ID, a.DIS_STR, a.SYS_ORDER, a.SYS_NAME,
			CSD_PRICE AS CSD_TOTAL_PRICE, NULL,
			CASE
				WHEN ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + ROUND(ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) * TX_PERCENT / 100, 2) > SL_REST THEN
					ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) - 0.01
				WHEN ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + ROUND(ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) * TX_PERCENT / 100, 2) < SL_REST THEN
					ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2) + 0.01
				ELSE ROUND((100 * SL_REST / (100 + TX_PERCENT)), 2)
			END AS SL_REST,
			c.PR_DATE AS ACT_MONTH,
			SN_ID, SN_NAME, SL_BEZ_NDS
		FROM
			dbo.SaldoTable
			INNER JOIN dbo.ClientTable ON CL_ID = SL_ID_CLIENT
			INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR
			INNER JOIN dbo.ConsignmentDetailTable ON CSD_ID = SL_ID_CONSIG_DIS
			INNER JOIN dbo.ConsignmentTable ON CSG_ID = CSD_ID_CONS
			INNER JOIN dbo.TaxTable ON TX_ID = CSD_ID_TAX
			INNER JOIN dbo.PeriodTable c ON PR_ID = CSD_ID_PERIOD
			INNER JOIN #tmpsystem ON a.SYS_ID = TSYS_ID
			LEFT JOIN dbo.DistrFinancingTable b ON DF_ID_DISTR = DIS_ID
			LEFT JOIN dbo.SystemNetTable ON SN_ID = DF_ID_NET

		WHERE SL_DATE BETWEEN @begindate AND @enddate
			AND (CSG_ID_ORG = @org OR @org IS NULL)

		ORDER BY a.SYS_ORDER, CL_PSEDO, CL_ID, a.DIS_ID, SL_DATE, SL_TP, SL_ID, ACT_MONTH

		IF OBJECT_ID('tempdb..#tmpsystem') IS NOT NULL
			DROP TABLE #tmpsystem

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[REPORT_ACT_SELECT] TO rl_report_act_r;
GO