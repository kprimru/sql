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
CREATE PROCEDURE [dbo].[INVOICE_CREATE_BY_INCOME_ALL]
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
	
		DECLARE INCOME CURSOR LOCAL FOR
			SELECT IN_ID
			FROM dbo.IncomeTable
			WHERE IN_ID_INVOICE IS NULL
				AND IN_DATE <= @invdate
				AND IN_SUM > 0

		OPEN INCOME

		DECLARE @inid INT
		

		DECLARE @invoiceid INT
		DECLARE @invoicestr VARCHAR(MAX)

		SET @invoicestr = ''

		FETCH NEXT FROM INCOME INTO @inid

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.INVOICE_CREATE_BY_INCOME @inid, @invdate, 0, 0, @invoiceid OUTPUT, 0

			IF @invoiceid IS NOT NULL
				SET @invoicestr = @invoicestr + CONVERT(VARCHAR, @invoiceid) + ','
			
			FETCH NEXT FROM INCOME INTO @inid
		END
		
		IF ISNULL(@invoicestr, '') <> ''
			SET @invoicestr = LEFT(@invoicestr, LEN(@invoicestr) - 1)

		CLOSE INCOME
		DEALLOCATE INCOME
		/*
		DECLARE RTRN CURSOR LOCAL FOR
			SELECT IN_ID
			FROM dbo.IncomeTable
			WHERE IN_ID_INVOICE IS NULL
				AND IN_DATE <= @invdate
				AND IN_SUM < 0

		OPEN INCOME

		FETCH NEXT FROM RTRN INTO @inid

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.INVOICE_CREATE_BY_RETURN @inid, @invdate, 0, 0, @invoiceid OUTPUT, 0

			IF @invoiceid IS NOT NULL
				SET @invoicestr = @invoicestr + CONVERT(VARCHAR, @invoiceid) + ','
			
			FETCH NEXT FROM RTRN INTO @inid
		END
		
		IF ISNULL(@invoicestr, '') <> ''
			SET @invoicestr = LEFT(@invoicestr, LEN(@invoicestr) - 1)

		CLOSE RTNR
		DEALLOCATE RTRN
		*/
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
