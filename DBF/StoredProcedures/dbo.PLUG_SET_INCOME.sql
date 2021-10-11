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

ALTER PROCEDURE [dbo].[PLUG_SET_INCOME]
	@incomeid INT
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

		UPDATE dbo.IncomeTable
		SET IN_ID_INVOICE =
			(
				SELECT INS_ID
				FROM dbo.InvoiceSaleTable
				WHERE INS_NUM = '0'
					AND INS_NUM_YEAR = '0'
			)
		WHERE IN_ID = @incomeid

		/*
		возвраты
		*/

		INSERT INTO dbo.BookPurchase(ID_ORG, ID_AVANS, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, PURCHASE_DATE)
			SELECT DISTINCT INS_ID_ORG, INS_ID, INS_ID, '22', INS_NUM, INS_DATE, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP, a.IN_PAY_NUM, a.IN_DATE, NULL
			FROM
				dbo.IncomeTable a
				INNER JOIN dbo.IncomeDistrTable b ON IN_ID = ID_ID_INCOME
				INNER JOIN dbo.IncomeDistrTable c ON c.ID_ID_DISTR = b.ID_ID_DISTR AND c.ID_ID_PERIOD = b.ID_ID_PERIOD
				INNER JOIN dbo.IncomeTable d ON d.IN_ID = c.ID_ID_INCOME
				INNER JOIN dbo.InvoiceSaleTable e ON e.INS_ID = d.IN_ID_INVOICE
			WHERE a.IN_ID = @incomeid
				AND a.IN_SUM < 0
				AND b.ID_PRICE < 0 AND c.ID_PRICE > 0

		INSERT INTO dbo.BookPurchaseDetail(ID_PURCHASE, ID_TAX, S_ALL, S_NDS, S_BEZ_NDS)
			SELECT
				(
					SELECT ID
					FROM dbo.BookPurchase z
					WHERE z.ID_AVANS = e.INS_ID
						AND z.ID_INVOICE = e.INS_ID
						AND z.CODE = '22'
				), TX_ID, SUM(-b.ID_PRICE), SUM(-b.ID_PRICE - (-b.ID_PRICE / ((100 + TX_PERCENT) / 100))), SUM((-b.ID_PRICE / ((100 + TX_PERCENT) / 100)))
			FROM
				dbo.IncomeTable a
				INNER JOIN dbo.IncomeDistrTable b ON IN_ID = ID_ID_INCOME
				INNER JOIN dbo.IncomeDistrTable c ON c.ID_ID_DISTR = b.ID_ID_DISTR AND c.ID_ID_PERIOD = b.ID_ID_PERIOD
				INNER JOIN dbo.IncomeTable d ON d.IN_ID = c.ID_ID_INCOME
				INNER JOIN dbo.InvoiceSaleTable e ON e.INS_ID = d.IN_ID_INVOICE
				INNER JOIN dbo.DistrView WITH(NOEXPAND) ON b.ID_ID_DISTR = DIS_ID
				INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
				INNER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
			WHERE a.IN_ID = @incomeid
				AND a.IN_SUM < 0
				AND b.ID_PRICE < 0 AND c.ID_PRICE > 0
			GROUP BY TX_ID, INS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PLUG_SET_INCOME] TO rl_invoice_w;
GO
