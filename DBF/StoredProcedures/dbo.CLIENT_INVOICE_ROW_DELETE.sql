USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	1-04-2009
Описание:		удалить несколько записей
				из таблицы счета-фактуры
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_ROW_DELETE]
	@rowlist VARCHAR(200)
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

		DECLARE @insid INT


		IF OBJECT_ID('tempdb..#dbf_invrow') IS NOT NULL
			DROP TABLE #dbf_invrow

		CREATE TABLE #dbf_invrow
			(
			ROW_ID INT NOT NULL
			)

		IF @rowlist IS NOT NULL
			BEGIN
			--парсить строчку и выбирать нужные значения
			INSERT INTO #dbf_invrow
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rowlist, ',')
			END

		SELECT @insid = INS_ID
		FROM
			dbo.InvoiceSaleTable a
			INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE = INS_ID
			INNER JOIN #dbf_invrow ON ROW_ID = INR_ID

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Удаление строки с/ф',
				ISNULL(INR_GOOD + ' ', '') + ISNULL(INR_NAME + ' ', '') +
				CASE ISNULL(INR_COUNT, 1)
					WHEN 1 THEN ''
					ELSE ' x' + CONVERT(VARCHAR(20), INR_COUNT) + ' - '
				END + dbo.MoneyFormat(INR_SALL)
			FROM
				dbo.InvoiceSaleTable a
				INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE = INS_ID
				INNER JOIN #dbf_invrow ON ROW_ID = INR_ID


		DELETE
		FROM
			dbo.InvoiceRowTable
		WHERE INR_ID IN (SELECT ROW_ID FROM #dbf_invrow)

		IF OBJECT_ID('tempdb..#dbf_invrow') IS NOT NULL
			DROP TABLE #dbf_invrow

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
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_ROW_DELETE] TO rl_invoice_d;
GO
