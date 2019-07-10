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

CREATE PROCEDURE [dbo].[INVOICE_TYPE_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.InvoiceTypeTable WHERE INT_ID = @id
END


