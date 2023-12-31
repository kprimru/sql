USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_CALC_SELECT]
	@PR_ID	SMALLINT
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

		DECLARE @PR_PREV	SMALLINT
		SET @PR_PREV = dbo.PERIOD_PREV(@PR_ID)

		DECLARE @PR_DATE	SMALLDATETIME
		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		DECLARE @TAX_PERCENT	DECIMAL(8, 4)

		SELECT @TAX_PERCENT = TX_PERCENT / 100
		FROM
			dbo.TaxTable
			INNER JOIN dbo.SaleObjectTable ON SO_ID_TAX = TX_ID
		WHERE SO_ID = 1

		DECLARE @NET_COEF	DECIMAL(8, 4)

		SELECT @NET_COEF = SN_COEF
		FROM
			dbo.SystemNetTable
			INNER JOIN dbo.SystemNetCountTable ON SNC_ID_SN = SN_ID
		WHERE SNC_NET_COUNT = 1

		SELECT
			SYS_ID, SYS_SHORT_NAME, SYS_MAIN, PS_PRICE, PC_COEF, PS_VMI,
			CONVERT(MONEY, 0) AS PS_PREV_PRICE,
			CONVERT(MONEY, 0) AS PS_COEF_PRICE,
			CONVERT(DECIMAL(8, 4), 0) AS PC_TOTAL_COEF,
			CONVERT(MONEY, 0) AS PS_TOTAL_PRICE,
			CONVERT(MONEY, 0) AS PS_PRICE_NDS,
			CONVERT(MONEY, 0) AS PS_PRICE_NET,
			CONVERT(DECIMAL(8, 4), 0) AS PS_RATIO,
			@TAX_PERCENT AS TX_PERCENT, @NET_COEF AS NT_COEF,
			SSC_COEF, PS_VMI_RIC, PS_SUBHOST,
			CONVERT(DECIMAL(8, 4), NULL) AS SSC_SUBHOST_COEF,
			CONVERT(DECIMAL(8, 4), NULL) AS SSC_RECOM_COEF
		FROM
			(
				SELECT
					SYS_ID, SYS_SHORT_NAME, SYS_ORDER,
					CONVERT(BIT, CASE
						WHEN EXISTS
							(
								SELECT *
								FROM dbo.SystemWeightTable
								WHERE SW_ID_SYSTEM = SYS_ID
									AND SW_ID_PERIOD = @PR_ID
							) THEN 1
						ELSE 0
					END) AS SYS_MAIN,
					b.PS_PRICE AS PS_PRICE,
					c.PS_PRICE AS PS_VMI,
					f.PS_PRICE AS PS_VMI_RIC,
					g.PS_PRICE AS PS_SUBHOST,
					ISNULL(ISNULL(e.PC_COEF, d.PC_COEF), 1) AS PC_COEF,
					ISNULL(SSC_COEF, 0) AS SSC_COEF
				FROM
					dbo.SystemTable a
					LEFT OUTER JOIN dbo.PriceSystemTable b ON a.SYS_ID = b.PS_ID_SYSTEM AND b.PS_ID_PERIOD = @PR_PREV AND b.PS_ID_TYPE = 1
					LEFT OUTER JOIN dbo.PriceSystemTable c ON a.SYS_ID = c.PS_ID_SYSTEM AND c.PS_ID_PERIOD = @PR_ID AND c.PS_ID_TYPE = 16
					LEFT OUTER JOIN dbo.PriceSystemTable f ON a.SYS_ID = f.PS_ID_SYSTEM AND f.PS_ID_PERIOD = @PR_ID AND f.PS_ID_TYPE = 15
					LEFT OUTER JOIN dbo.PriceSystemTable g ON a.SYS_ID = g.PS_ID_SYSTEM AND g.PS_ID_PERIOD = @PR_PREV AND g.PS_ID_TYPE = 27
					LEFT OUTER JOIN dbo.PriceCoef d ON d.PC_ID_SYSTEM = a.SYS_ID AND d.PC_ID_PERIOD = @PR_PREV
					LEFT OUTER JOIN dbo.PriceCoef e ON e.PC_ID_SYSTEM = a.SYS_ID AND d.PC_ID_PERIOD = @PR_ID
					LEFT OUTER JOIN dbo.SystemSubhostCoefGet(@PR_DATE) ON SSC_ID_SYSTEM = SYS_ID
				WHERE SYS_ID_SO = 1 AND SYS_ACTIVE = 1
			) AS t
		ORDER BY SYS_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_CALC_SELECT] TO rl_price_calc;
GO
