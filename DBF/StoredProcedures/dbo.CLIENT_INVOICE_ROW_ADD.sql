USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	31.03.2009
Описание:		добавление строки таблицы счета-фактуры
*/
ALTER PROCEDURE [dbo].[CLIENT_INVOICE_ROW_ADD]
	@INR_ID_INVOICE INT,
	@INR_ID_DISTR INT,
	@INR_GOOD VARCHAR(100),
	@INR_NAME VARCHAR(500),
	@INR_SUM MONEY,
	@INR_ID_TAX SMALLINT,
	@INR_TNDS DECIMAL(6, 4),
	@INR_SNDS MONEY,
	@INR_SALL MONEY,
	@inrunit VARCHAR(100),
	@inrcount smallint,
	@period smallint = null

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
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Добавление строки с/ф',
				ISNULL(@INR_GOOD + ' ', '') + ISNULL(@INR_NAME + ' ', '') +
				CASE ISNULL(@inrcount, 1)
					WHEN 1 THEN ''
					ELSE ' x' + CONVERT(VARCHAR(20), @inrcount) + ' - '
				END + dbo.MoneyFormat(@INR_SALL)
			FROM
				dbo.InvoiceSaleTable a
			WHERE INS_ID = @INR_ID_INVOICE

		INSERT INTO dbo.InvoiceRowTable
			(INR_ID_INVOICE, INR_ID_DISTR, INR_GOOD, INR_NAME, INR_SUM, INR_ID_TAX, INR_TNDS, INR_SNDS, INR_SALL, INR_UNIT, INR_COUNT, INR_ID_PERIOD) VALUES
			(@INR_ID_INVOICE, @INR_ID_DISTR, @INR_GOOD, @INR_NAME, @INR_SUM, @INR_ID_TAX, @INR_TNDS, @INR_SNDS, @INR_SALL, @inrunit, @inrcount, @period)

		DECLARE @newiden int
		SET @newiden = SCOPE_IDENTITY()

		SELECT @newiden AS NEW_IDEN

		EXEC dbo.BOOK_SALE_PROCESS @INR_ID_INVOICE
		EXEC dbo.BOOK_PURCHASE_PROCESS @INR_ID_INVOICE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_ROW_ADD] TO rl_invoice_w;
GO
