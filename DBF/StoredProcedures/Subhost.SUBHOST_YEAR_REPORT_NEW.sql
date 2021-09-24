USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_YEAR_REPORT_NEW]
	@PR_MIN	SMALLINT,
	@PR_LIST	VARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		CREATE TABLE #period
			(
				TPR_ID SMALLINT PRIMARY KEY,
				TX_TOTAL_RATE	DECIMAL(8,4)
			)

		IF @PR_MIN IS NOT NULL
			INSERT INTO #period(TPR_ID, TX_TOTAL_RATE)
				SELECT DISTINCT PR_ID, TX_TOTAL_RATE
				FROM
					dbo.PeriodTable
					INNER JOIN Subhost.SubhostCalc ON PR_ID = SHC_ID_PERIOD
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_MIN)
					AND PR_DATE >= '20111101'
		ELSE
			INSERT INTO #period(TPR_ID, TX_TOTAL_RATE)
				SELECT PR_ID, TX_TOTAL_RATE
				FROM
					dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
					INNER JOIN dbo.PeriodTable ON PR_ID = Item
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= '20111101'

		SELECT
			ROW_NUMBER() OVER(PARTITION BY SH_ORDER ORDER BY SH_ORDER, PR_DATE) AS RN,
			SHC_ID_SUBHOST, SH_FULL_NAME, SH_ORDER, SHC_ID_PERIOD, PR_NAME, PR_DATE,
			DELIVERY_SUM, SUP_SUM, SUP_COM_COUNT, SUP_SPEC_COUNT,
				ISNULL(DELIVERY_SUM, 0) +
				ISNULL(SUP_SUM, 0) +
				ISNULL(SHC_PAPPER, 0) +
				ISNULL(SHC_DELIVERY, 0) +
				ISNULL(SHC_TRAFFIC, 0) -
				ISNULL(SHC_DIU, 0) +
				ISNULL(SP_STUDY, 0) +
				ISNULL(SP_10, 0) +
				ISNULL(SP_MARKET, 0) -
				ISNULL(SHP_STUDY, 0) AS TOTAL,

			CONVERT(MONEY,
				ROUND(
						(
							ISNULL(DELIVERY_SUM, 0) +
							ISNULL(SUP_SUM, 0) +
							ISNULL(SHC_PAPPER, 0) +
							ISNULL(SHC_DELIVERY, 0) +
							ISNULL(SHC_TRAFFIC, 0) -
							ISNULL(SHC_DIU, 0) +
							ISNULL(SP_STUDY, 0) +
							ISNULL(SP_MARKET, 0) -
							ISNULL(SHP_STUDY, 0)
						) * TX_TOTAL_RATE, 2) + ISNULL(SHC_DIU, 0) +

			ROUND(ISNULL(SP_10, 0) * 1.1, 2)) AS TOTAL_NDS,
			SHP_SUM AS PAY,
			SHP_DEBT AS DEBT
		FROM
			(
				SELECT
					TX_TOTAL_RATE,

					SS_ID AS SHC_ID_SUBHOST, SH_FULL_NAME, SH_ORDER,
					a.PR_ID AS SHC_ID_PERIOD, PR_NAME, PR_DATE,
					SCR_PAPPER AS SHC_PAPPER,
					SCR_TRAFFIC AS SHC_TRAFFIC, SCR_DIU AS SHC_DIU, SCR_DELIVERY AS SHC_DELIVERY,
					SCR_DELIVERY_SYS AS DELIVERY_SUM,
					SCR_CNT AS SUP_COM_COUNT,
					SCR_CNT_SPEC AS SUP_SPEC_COUNT,
					SCR_SUPPORT AS SUP_SUM,
					SCR_NDS10 AS SP_10,
					SCR_STUDY AS SP_STUDY,
					SCR_MARKET AS SP_MARKET,
					SCR_IC AS SHP_STUDY,
					SCR_DEBT AS SHP_DEBT,
					SCR_INCOME AS SHP_SUM
				FROM
					#period c
					CROSS JOIN
					(
						SELECT DISTINCT SHC_ID_SUBHOST AS SS_ID
						FROM
							Subhost.SubhostCalc
							INNER JOIN #period ON TPR_ID = SHC_ID_PERIOD
					) AS dt
					LEFT OUTER JOIN Subhost.SubhostCalcReport ON c.TPR_ID = SCR_ID_PERIOD AND SCR_ID_SUBHOST = SS_ID
					LEFT OUTER JOIN dbo.PeriodTable a ON PR_ID = TPR_ID
					LEFT OUTER JOIN dbo.SubhostTable t ON t.SH_ID = SS_ID
			) AS o_O
		WHERE SHC_ID_PERIOD IS NOT NULL
		ORDER BY SH_ORDER, PR_DATE


		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		IF OBJECT_ID('tempdb..#delivery') IS NOT NULL
			DROP TABLE #delivery

		IF OBJECT_ID('tempdb..#support') IS NOT NULL
			DROP TABLE #support

		IF OBJECT_ID('tempdb..#sup_list') IS NOT NULL
			DROP TABLE #sup_list

		IF OBJECT_ID('tempdb..#con_list') IS NOT NULL
			DROP TABLE #con_list

		IF OBJECT_ID('tempdb..#comp_list') IS NOT NULL
			DROP TABLE #comp_list

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_YEAR_REPORT_NEW] TO rl_subhost_calc;
GO
