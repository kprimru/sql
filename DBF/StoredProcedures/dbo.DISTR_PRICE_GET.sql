USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_PRICE_GET]
	@distrid INT,
	@periodid SMALLINT
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

		SELECT TOP 1 DIS_PRICE, CAST(ROUND(DIS_PRICE * (TX_PERCENT/100 + 1), 2) AS MONEY) AS DIS_TAX_PRICE
		FROM
			dbo.DistrPriceView INNER JOIN
			dbo.SaleObjectTable ON SO_ID = SYS_ID_SO INNER JOIN
			dbo.TaxTable ON TX_ID = SO_ID_TAX
		WHERE DIS_ID = @distrid
			AND PR_DATE <
					(
						SELECT PR_DATE
						FROM dbo.PeriodTable
						WHERE PR_ID = @periodid
					)
		ORDER BY PR_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_PRICE_GET] TO rl_income_w;
GO
