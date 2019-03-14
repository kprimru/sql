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

CREATE PROCEDURE [dbo].[INVOICE_ACT_DEFAULT_GET]
	@invoiceid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 CO_NUM, CO_DATE
	FROM 
		dbo.ContractTable INNER JOIN
		dbo.ClientTable ON CL_ID = CO_ID_CLIENT INNER JOIN
		dbo.InvoiceSaleTable ON INS_ID_CLIENT = CL_ID
	WHERE INS_ID = @invoiceid AND CO_ACTIVE = 1
END
