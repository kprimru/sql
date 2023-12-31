USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_REPORT_PRODUCT_GET]
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
				TPR_ID SMALLINT PRIMARY KEY
			)

		IF @PR_MIN IS NOT NULL
			INSERT INTO #period(TPR_ID)
				SELECT PR_ID
				FROM
					dbo.PeriodTable
					INNER JOIN Subhost.SubhostCalc ON PR_ID = SHC_ID_PERIOD
				WHERE SHC_ID_SUBHOST = @SH_ID
					AND PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_MIN)
		ELSE
			INSERT INTO #period(TPR_ID)
				SELECT PR_ID
				FROM
					dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
					INNER JOIN dbo.PeriodTable ON PR_ID = Item

		SELECT
			SPG_ID, ROW_NUMBER() OVER (ORDER BY SP_NAME) AS SP_ORDER, SP_NAME,
			ISNULL(SPC_COUNT, 0) AS SPC_COUNT,
			ISNULL(CONVERT(MONEY, ROUND(SPP_PRICE * (100 + ISNULL(SP_COEF, 0))/100, 2)), 0) AS SPP_PRICE,
			ISNULL(SPC_COUNT, 0) * ISNULL(CONVERT(MONEY, ROUND(SPP_PRICE * (100 + ISNULL(SP_COEF, 0))/100, 2)), 0) AS SPP_TOTAL
		FROM
			Subhost.SubhostProduct
			INNER JOIN Subhost.SubhostProductGroup ON SPG_ID = SP_ID_GROUP
			LEFT OUTER JOIN Subhost.SubhostProductCalc ON SPC_ID_PROD = SP_ID 
									AND SPC_ID_SUBHOST = @SH_ID
			LEFT OUTER JOIN #period ON SPC_ID_PERIOD = TPR_ID
			LEFT OUTER JOIN Subhost.SubhostProductPrice ON SPP_ID_PERIOD = TPR_ID
												AND SPP_ID_PRODUCT = SP_ID
		WHERE SPG_ID = 3
		ORDER BY TPR_ID, SP_ORDER, SP_NAME

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
GRANT EXECUTE ON [Subhost].[SUBHOST_REPORT_PRODUCT_GET] TO rl_subhost_calc;
GO
