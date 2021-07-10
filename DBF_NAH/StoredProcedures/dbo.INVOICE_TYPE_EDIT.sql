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

ALTER PROCEDURE [dbo].[INVOICE_TYPE_EDIT]
	@id SMALLINT,
	@name VARCHAR(100),
	@psedo VARCHAR(50),
	@sale BIT,
	@buy BIT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.InvoiceTypeTable
	SET INT_NAME = @name,
		INT_PSEDO = @psedo,
		INT_SALE = @sale,
		INT_BUY = @buy,
		INT_ACTIVE = @active
	WHERE INT_ID = @id
END





GO
GRANT EXECUTE ON [dbo].[INVOICE_TYPE_EDIT] TO rl_invoice_type_w;
GO