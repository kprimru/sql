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

CREATE PROCEDURE [dbo].[CONSIGNMENT_DELIVERY]
	@csgid INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_CLIENT = @clientid,
		CSG_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
	WHERE CSG_ID = @csgid

	UPDATE dbo.InvoiceSaleTable
	SET INS_ID_CLIENT = @clientid,
		INS_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
	WHERE INS_ID = 
		(
			SELECT CSG_ID_INVOICE 
			FROM dbo.ConsignmentTable 
			WHERE CSG_ID = @csgid
		)

	UPDATE dbo.SaldoTable
	SET SL_ID_CLIENT = @clientid
	WHERE SL_ID_CONSIG_DIS IN
		(
			SELECT CSD_ID
			FROM dbo.ConsignmentDetailTable
			WHERE CSD_ID_CONS = @csgid
		)
END
