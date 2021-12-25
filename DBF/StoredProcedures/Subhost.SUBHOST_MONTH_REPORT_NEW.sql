USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_MONTH_REPORT_NEW]
	@SH_ID	SMALLINT,
	@PR_MIN	SMALLINT,
	@PR_LIST	VARCHAR(MAX)
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
				TX_RATE	DECIMAL(8,4)
			)

		IF @PR_MIN IS NOT NULL
			INSERT INTO #period(TPR_ID, TX_RATE)
				SELECT PR_ID, TX_TAX_RATE
				FROM
					dbo.PeriodTable
					INNER JOIN Subhost.SubhostCalc ON PR_ID = SHC_ID_PERIOD
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE SHC_ID_SUBHOST = @SH_ID
					AND PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_MIN)
					AND PR_DATE >= '20111101'
		ELSE
			INSERT INTO #period(TPR_ID, TX_RATE)
				SELECT PR_ID, TX_TAX_RATE
				FROM
					dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
					INNER JOIN dbo.PeriodTable ON PR_ID = Item
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= '20111101'

		SELECT
			TX_RATE,
			SCR_ID_PERIOD AS SHC_ID_PERIOD, PR_NAME, 
			SCR_PAPPER AS SHC_PAPPER,
			SCR_TRAFFIC AS SHC_TRAFFIC, SCR_DIU AS SHC_DIU, SCR_DELIVERY AS SHC_DELIVERY,
			SHC_INV_NUM, SHC_INV_DATE,
			SCR_DELIVERY_SYS AS DELIVERY_SUM,
			SCR_CNT AS SUP_COM_COUNT,
			SCR_CNT_SPEC AS SUP_SPEC_COUNT,
			SCR_SUPPORT AS SUP_SUM,
			SCR_NDS10 AS SP_10,
			SCR_STUDY AS SP_STUDY,
			SCR_MARKET AS SP_MARKET,
			SCR_IC SHP_STUDY,
			SCR_INCOME, SCR_DEBT,
			SCR_PENALTY AS SHP_PENALTY,
			SCR_INCOME AS SHP_SUM,
			SCR_DEBT AS SHP_DEBT
		FROM
			Subhost.SubhostCalc
			INNER JOIN Subhost.SubhostCalcReport ON SHC_ID_PERIOD = SCR_ID_PERIOD AND SHC_ID_SUBHOST = SCR_ID_SUBHOST
			INNER JOIN #period c ON c.TPR_ID = SHC_ID_PERIOD
			INNER JOIN dbo.PeriodTable a ON PR_ID = TPR_ID
			INNER JOIN dbo.SubhostTable z ON z.SH_ID = SHC_ID_SUBHOST
		WHERE SHC_ID_SUBHOST = @SH_ID
		ORDER BY PR_DATE


		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_MONTH_REPORT_NEW] TO rl_subhost_calc;
GO
