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

ALTER PROCEDURE [dbo].[INVOICE_DELIVERY]
	@insid INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT
			INS_ID_CLIENT, @insid, 'INVOICE', 'Передача с/ф',
			'№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR) +
			' от ' + b.CL_FULL_NAME + ' к ' + ISNULL((SELECT CL_FULL_NAME FROM dbo.CLientTable WHERE CL_ID = @clientid), '')
		FROM
			dbo.InvoiceSaleTable a
			INNER JOIN dbo.ClientTable b ON a.INS_ID_CLIENT = b.CL_ID
		WHERE INS_ID = @insid

	UPDATE dbo.InvoiceSaleTable
	SET INS_ID_CLIENT = @clientid,
		INS_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
	WHERE INS_ID = @insid

END

GO
GRANT EXECUTE ON [dbo].[INVOICE_DELIVERY] TO rl_invoice_w;
GO