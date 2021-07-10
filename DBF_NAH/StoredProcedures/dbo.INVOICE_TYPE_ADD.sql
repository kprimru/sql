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

ALTER PROCEDURE [dbo].[INVOICE_TYPE_ADD]
	@name VARCHAR(100),
	@psedo VARCHAR(50),
	@sale BIT,
	@buy BIT,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.InvoiceTypeTable(INT_NAME, INT_PSEDO, INT_SALE, INT_BUY, INT_ACTIVE)
	VALUES (@name, @psedo, @sale, @buy, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END





GO
GRANT EXECUTE ON [dbo].[INVOICE_TYPE_ADD] TO rl_invoice_type_w;
GO