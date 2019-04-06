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

CREATE PROCEDURE [dbo].[INVOICE_SET_INCOME]
	@incomeid INT,
	@invoiceid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeTable
	SET IN_ID_INVOICE = @invoiceid
	WHERE IN_ID = @incomeid
END
