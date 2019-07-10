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

CREATE PROCEDURE [dbo].[INCOME_DELIVERY]
	@incomeid INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeTable
	SET IN_ID_CLIENT = @clientid,
		IN_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
	WHERE IN_ID = @incomeid

	UPDATE dbo.InvoiceSaleTable
	SET INS_ID_CLIENT = @clientid,
		INS_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
	WHERE INS_ID = 
		(
			SELECT IN_ID_INVOICE 
			FROM dbo.IncomeTable 
			WHERE IN_ID = @incomeid
		)

	UPDATE dbo.SaldoTable
	SET SL_ID_CLIENT = @clientid
	WHERE SL_ID_IN_DIS IN
		(
			SELECT ID_ID
			FROM dbo.IncomeDistrTable
			WHERE ID_ID_INCOME = @incomeid
		)
END
