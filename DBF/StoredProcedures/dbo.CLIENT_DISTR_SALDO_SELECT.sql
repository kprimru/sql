USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_SALDO_SELECT]
	@clientid INT,
	@distrid INT
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

		SELECT
			a.SL_ID, SL_TP, CL_FULL_NAME, SL_DATE, a.DIS_STR, BD_TOTAL_PRICE, a.ID_PRICE, AD_TOTAL_PRICE,
			CSD_TOTAL_PRICE, a.SL_REST, a.SL_BEZ_NDS, BPR_DATE, a.IN_DATE, IN_PAY_NUM, APR_DATE, CPR_DATE, b.DELTA AS SL_DELTA,
			CASE TX_PERCENT
				WHEN 0 THEN 0
				ELSE
					CAST(ROUND((a.ID_PRICE - b.DELTA) - CAST(ROUND((a.ID_PRICE - b.DELTA) /(1 + ROUND(TX_PERCENT / 100, 2)), 2) AS MONEY), 2) AS MONEY)
			END AS AVANS
		FROM
			dbo.SaldoDetailView a
			LEFT OUTER JOIN dbo.IncomeSaldoView b ON a.SL_ID = b.SL_ID
			LEFT OUTER JOIN dbo.DistrView z WITH(NOEXPAND) ON ID_ID_DISTR = z.DIS_ID
			LEFT OUTER JOIN dbo.SaleObjectTable ON SYS_ID_SO = SO_ID
			LEFT OUTER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
		WHERE CL_ID = @clientid AND a.DIS_ID = @distrid
		ORDER BY SL_DATE , SL_TP , SL_ID, APR_DATE, IPR_DATE, BPR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_SALDO_SELECT] TO rl_saldo_r;
GO