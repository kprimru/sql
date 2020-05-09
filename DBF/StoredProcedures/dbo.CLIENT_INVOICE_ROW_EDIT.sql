USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	1.04.2009
Описание:		строка таблицы счета-фактуры
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_ROW_EDIT]
	@rowid INT,--	INR_ID,
	@INR_ID_DISTR INT,
	@INR_GOOD VARCHAR(100),
	@INR_NAME VARCHAR(500),
	@INR_SUM MONEY,
	@INR_ID_TAX SMALLINT,
	@INR_TNDS DECIMAL(6, 4),
	@INR_SNDS MONEY,
	@INR_SALL MONEY,
	@inrunit VARCHAR(100),
	@inrcount SMALLINT = null,
	@period		SMALLINT = NULL
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
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Изменение строки с/ф',
				CASE
					WHEN ISNULL(@INR_GOOD, '') <> ISNULL(INR_GOOD, '') THEN 'Текст услуги: с "' + ISNULL(INR_GOOD, '') + '" на "' + ISNULL(@INR_GOOD, '') + '" '
					ELSE ''
				END +
				CASE
					WHEN ISNULL(@INR_NAME, '') <> ISNULL(INR_NAME, '') THEN 'Услуга: с "' + ISNULL(INR_NAME, '') + '" на "' + ISNULL(@INR_NAME, '') + '" '
					ELSE ''
				END +
				CASE
					WHEN ISNULL(@inrcount, 1) <> ISNULL(INR_COUNT, 1) THEN 'Кол-во: с "' + CONVERT(VARCHAR(20), ISNULL(INR_COUNT, 1)) + '" на "' + CONVERT(VARCHAR(20), ISNULL(@inrcount, 1)) + '" '
					ELSE ''
				END +
				CASE
					WHEN @INR_SALL <> INR_SALL THEN 'Сумма: с "' + dbo.MoneyFormat(INR_SALL) + '" на "' + dbo.MoneyFormat(@INR_SALL) + '"'
					ELSE ''
				END
			FROM
				dbo.InvoiceSaleTable a
				INNER JOIN dbo.InvoiceRowTable b ON a.INS_ID = INR_ID_INVOICE
			WHERE INR_ID = @rowid AND
				(
					ISNULL(@INR_GOOD, '') <> ISNULL(INR_GOOD, '')
					OR ISNULL(@INR_NAME, '') <> ISNULL(INR_NAME, '')
					OR ISNULL(@inrcount, 1) <> ISNULL(INR_COUNT, 1)
					OR @INR_SALL <> INR_SALL
				)

		UPDATE	dbo.InvoiceRowTable
		SET INR_ID_DISTR = @INR_ID_DISTR,
			INR_GOOD = @INR_GOOD,
			INR_NAME=@INR_NAME,
			INR_SUM=@INR_SUM,
			INR_ID_TAX=@INR_ID_TAX,
			INR_TNDS=@INR_TNDS,
			INR_SNDS=@INR_SNDS,
			INR_SALL=@INR_SALL,
			INR_UNIT = @inrunit,
			INR_COUNT = @inrcount,
			INR_ID_PERIOD = @period
		WHERE INR_ID = @rowid

		DECLARE @insid INT
		SELECT @insid = INR_ID_INVOICE
		FROM dbo.InvoiceRowTable
		WHERE INR_ID = @rowid

		EXEC dbo.BOOK_SALE_PROCESS @insid
		EXEC dbo.BOOK_PURCHASE_PROCESS @insid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_ROW_EDIT] TO rl_invoice_w;
GO