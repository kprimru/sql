USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[INVOICE_SET_CONSIGN]
	@consid INT,
	@invoiceid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_INVOICE = @invoiceid
	WHERE CSG_ID = @consid
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_SET_CONSIGN] TO rl_invoice_w;
GO