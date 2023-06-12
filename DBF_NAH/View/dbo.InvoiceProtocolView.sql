USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[InvoiceProtocolView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[InvoiceProtocolView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[InvoiceProtocolView]
AS
	SELECT
		INS_ID, INS_ID_CLIENT,
		'С/ф №' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' сумма: ' +
			(
				SELECT dbo.MoneyFormat(SUM(INR_SALL))
				FROM dbo.InvoiceRowTable
				WHERE INR_ID_INVOICE = INS_ID
			) + ' (' +
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						ISNULL(INR_GOOD + ' ', '') + ISNULL(DIS_STR + ' ', '') + ISNULL(INR_NAME + ' ', '') +
						CASE ISNULL(INR_COUNT, 1)
							WHEN 1 THEN ''
							ELSE ' x' + CONVERT(VARCHAR(20), INR_COUNT) + ' - '
						END + dbo.MoneyFormat(INR_SALL) + ', '
					FROM
						dbo.InvoiceRowTable
						LEFT OUTER JOIN dbo.DistrView WITH(NOEXPAND) ON INR_ID_DISTR = DIS_ID
						LEFT OUTER JOIN dbo.PeriodTable ON PR_ID = INR_ID_PERIOD
					WHERE INR_ID_INVOICE = INS_ID
					ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM, INR_NAME FOR XML PATH('')
				)
			), 1, 2, '')) + ')'
		AS INS_DATA
	FROM dbo.InvoiceSaleTable
GO
