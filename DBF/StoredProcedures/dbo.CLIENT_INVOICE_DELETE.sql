USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	2-04-2009
Описание:		удалят все записи из таблицы строк счета-фактуры,
				а потом саму счет-фактуру
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_DELETE]
	@invid INT
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
	
		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Удаление строки с/ф',
				ISNULL(INR_GOOD + ' ', '') + ISNULL(INR_NAME + ' ', '') + 
				CASE ISNULL(INR_COUNT, 1) 
					WHEN 1 THEN ''
					ELSE ' x' + CONVERT(VARCHAR(20), INR_COUNT) + ' - '
				END + dbo.MoneyFormat(INR_SALL)
			FROM 
				dbo.InvoiceRowTable a
				INNER JOIN dbo.InvoiceSaleTable ON INR_ID_INVOICE = INS_ID
			WHERE INS_ID = @invid

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Удаление с/ф', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' от ' + CONVERT(VARCHAR(20), INS_DATE, 104)
			FROM 
				dbo.InvoiceSaleTable
			WHERE INS_ID = @invid

		DELETE FROM dbo.BookSaleDetail WHERE ID_SALE IN (SELECT ID FROM dbo.BookSale WHERE ID_INVOICE = @invid)
		DELETE FROM dbo.BookSale WHERE ID_INVOICE = @invid
		DELETE FROM dbo.BookPurchaseDetail WHERE ID_PURCHASE IN (SELECT ID FROM dbo.BookPurchase WHERE ID_INVOICE = @invid OR ID_AVANS = @invid)
		DELETE FROM dbo.BookPurchase WHERE ID_INVOICE = @invid OR ID_AVANS = @invid

		UPDATE dbo.IncomeTable
		SET IN_ID_INVOICE = NULL
		WHERE IN_ID_INVOICE = @invid

		UPDATE dbo.ActTable
		SET ACT_ID_INVOICE = NULL
		WHERE ACT_ID_INVOICE = @invid

		UPDATE dbo.ConsignmentTable
		SET CSG_ID_INVOICE = NULL
		WHERE CSG_ID_INVOICE = @invid

		UPDATE dbo.PrimaryPayTable
		SET PRP_ID_INVOICE = NULL
		WHERE PRP_ID_INVOICE = @invid

		DELETE FROM	dbo.InvoiceRowTable
		WHERE INR_ID_INVOICE = @invid

		DELETE FROM	dbo.InvoiceSaleTable
		WHERE INS_ID = @invid	
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_DELETE] TO rl_invoice_d;
GO