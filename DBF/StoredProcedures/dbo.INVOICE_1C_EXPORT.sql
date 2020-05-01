USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[INVOICE_1C_EXPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	INT
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

		IF OBJECT_ID('tempdb..#inv') IS NOT NULL
			DROP TABLE #inv

		SELECT
			INS_NUM, INS_DATE,
			INS_ID_CLIENT, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP,
			INS_DOC_STRING,
			--REPLACE(REPLACE(INS_DOC_STRING, '№ ', ''), 'от ', '') As INS_DOC_STRING,
			CASE
				WHEN ISNULL(INS_DOC_STRING, '') = '' THEN NULL
				ELSE RIGHT(RTRIM(INS_DOC_STRING), 10)
			END AS INS_DOC_DATE,
			CASE
				WHEN ISNULL(INS_DOC_STRING, '') = '' THEN ''
				WHEN CHARINDEX(';', INS_DOC_STRING) <> 0 THEN LTRIM(REPLACE(REPLACE(RTRIM(LEFT(RIGHT(INS_DOC_STRING, LEN(INS_DOC_STRING) - CHARINDEX(';', REVERSE(INS_DOC_STRING)) + 1), CHARINDEX('от', RIGHT(INS_DOC_STRING, LEN(INS_DOC_STRING) - CHARINDEX(';', REVERSE(INS_DOC_STRING)) - 1)))), '№', ''), 'N', ''))
				ELSE LTRIM(REPLACE(REPLACE(RTRIM(LEFT(INS_DOC_STRING, CHARINDEX('от', INS_DOC_STRING) - 1)), '№', ''), 'N', ''))
			END AS INS_DOC_NUM,
			CASE INT_PSEDO WHEN 'INCOME' THEN 1 ELSE 0 END AS AVANS,
			(
				SELECT SUM(INR_SUM * ISNULL(INR_COUNT, 1))
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 18
			) AS [18_PRICE],
			(
				SELECT SUM(INR_SNDS)
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 18
			) AS [18_NDS],
			(
				SELECT SUM(INR_SALL)
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 18
			) AS [18_SUM],
			(
				SELECT SUM(INR_SUM * ISNULL(INR_COUNT, 1))
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 10
			) AS [10_PRICE],
			(
				SELECT SUM(INR_SNDS)
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 10
			) AS [10_NDS],
			(
				SELECT SUM(INR_SALL)
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 10
			) AS [10_SUM],
			(
				SELECT SUM(INR_SUM * ISNULL(INR_COUNT, 1))
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 0
			) AS [0_PRICE],
			(
				SELECT SUM(INR_SNDS)
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 0
			) AS [0_NDS],
			(
				SELECT SUM(INR_SALL)
				FROM
					dbo.InvoiceRowTable
					INNER JOIN dbo.TaxTable ON TX_ID = INR_ID_TAX
				WHERE INR_ID_INVOICE = INS_ID AND TX_PERCENT = 0
			) AS [0_SUM]
		INTO #inv
		FROM
			dbo.InvoiceSaleTable
			INNER JOIN dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
		WHERE INS_DATE >= @BEGIN AND INS_DATE <= @END
			AND INS_ID_ORG = @ORG
		ORDER BY INS_NUM

		SELECT TOP 10 *
		FROM #inv
		WHERE [10_PRICE]  IS NOT NULL

		UNION ALL

		SELECT TOP 10 *
		FROM #inv
		WHERE [18_PRICE] IS NOT NULL AND [10_PRICE] IS NULL

		UNION ALL

		SELECT TOP 10 *
		FROM #inv
		WHERE [0_PRICE] IS NOT NULL

		UNION ALL

		SELECT TOP 10 *
		FROM #inv
		WHERE [18_PRICE] IS NOT NULL AND [10_PRICE] IS NOT NULL
		ORDER BY INS_NUM

		IF OBJECT_ID('tempdb..#inv') IS NOT NULL
			DROP TABLE #inv

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INVOICE_1C_EXPORT] TO rl_book_buy_p;
GRANT EXECUTE ON [dbo].[INVOICE_1C_EXPORT] TO rl_book_sale_p;
GO