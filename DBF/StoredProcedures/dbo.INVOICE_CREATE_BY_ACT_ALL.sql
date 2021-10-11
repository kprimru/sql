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
ALTER PROCEDURE [dbo].[INVOICE_CREATE_BY_ACT_ALL]
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

		DECLARE ACT CURSOR LOCAL FOR
			SELECT ACT_ID
			FROM dbo.ActTable
			WHERE ACT_ID_INVOICE IS NULL
				AND ACT_DATE <= @invdate

		OPEN ACT

		DECLARE @actid INT

		DECLARE @invoiceid INT
		DECLARE @invoicestr VARCHAR(MAX)

		SET @invoicestr = ''

		FETCH NEXT FROM ACT INTO @actid

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.INVOICE_CREATE_BY_ACT @actid, @invdate, 0, 0, @invoiceid OUTPUT, 0

			--SELECT @invoiceid

			IF @invoiceid IS NOT NULL
				SET @invoicestr = @invoicestr + CONVERT(VARCHAR, @invoiceid) + ','

			FETCH NEXT FROM ACT INTO @actid
		END

		--SELECT @invoicestr

		IF ISNULL(@invoicestr, '') <> ''
			SET @invoicestr = LEFT(@invoicestr, LEN(@invoicestr) - 1)

		CLOSE ACT
		DEALLOCATE ACT

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
GRANT EXECUTE ON [dbo].[INVOICE_CREATE_BY_ACT_ALL] TO rl_invoice_w;
GO
