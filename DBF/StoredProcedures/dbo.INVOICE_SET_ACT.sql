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

CREATE PROCEDURE [dbo].[INVOICE_SET_ACT]
	@actid INT,
	@invoiceid INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Изменение привязки к счету-фактуры', 'Был номер ' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) + ' стал номер ' + (SELECT CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) FROM dbo.InvoiceSaleTable WHERE INS_ID = @invoiceid)
		FROM 
			dbo.ActTable a
			INNER JOIN dbo.InvoiceSaleTable b ON a.ACT_ID_INVOICE = b.INS_ID
		WHERE a.ACT_ID = @actid

	UPDATE dbo.ActTable
	SET ACT_ID_INVOICE = @invoiceid
	WHERE ACT_ID = @actid
END
