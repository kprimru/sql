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
ALTER PROCEDURE [dbo].[INVOICE_CREATE_BY_CONSIGN_ALL]
	@invdate SMALLDATETIME,
	@print BIT
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

		DECLARE CONS CURSOR LOCAL FOR
			SELECT CSG_ID
			FROM
				dbo.ConsignmentTable
			WHERE CSG_DATE = @invdate
				AND CSG_ID_INVOICE IS NULL

		OPEN CONS

		DECLARE @consid INT

		DECLARE @invoiceid INT
		DECLARE @invoicestr VARCHAR(MAX)

		SET @invoicestr = ''

		FETCH NEXT FROM CONS INTO @consid

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.INVOICE_CREATE_BY_CONSIGN @consid, @invdate, 0, 0, @invoiceid OUTPUT, 0

			IF @invoiceid IS NOT NULL
				SET @invoicestr = @invoicestr + CONVERT(VARCHAR, @invoiceid) + ','


			FETCH NEXT FROM CONS INTO @consid
		END

		IF ISNULL(@invoicestr, '') <> ''
			SET @invoicestr = LEFT(@invoicestr, LEN(@invoicestr) - 1)

		CLOSE CONS
		DEALLOCATE CONS

		IF @print = 1
			EXEC dbo.INVOICE_PRINT_BY_ID_LIST @invoicestr, 0
		ELSE
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@invoicestr, ',')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_CREATE_BY_CONSIGN_ALL] TO rl_invoice_w;
GO