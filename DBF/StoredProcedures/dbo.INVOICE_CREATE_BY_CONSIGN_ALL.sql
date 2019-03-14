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
CREATE PROCEDURE [dbo].[INVOICE_CREATE_BY_CONSIGN_ALL]
	@invdate SMALLDATETIME,
	@print BIT
AS
BEGIN
	SET NOCOUNT ON;
	
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
END