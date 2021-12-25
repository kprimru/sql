USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[INVOICE_SET_ACT]
	@actid INT,
	@invoiceid INT
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
			SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Изменение привязки к счету-фактуры', 'Был номер ' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' стал номер ' + (SELECT CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) FROM dbo.InvoiceSaleTable WHERE INS_ID = @invoiceid)
			FROM
				dbo.ActTable a
				INNER JOIN dbo.InvoiceSaleTable b ON a.ACT_ID_INVOICE = b.INS_ID
			WHERE a.ACT_ID = @actid

		UPDATE dbo.ActTable
		SET ACT_ID_INVOICE = @invoiceid
		WHERE ACT_ID = @actid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_SET_ACT] TO rl_invoice_w;
GO
