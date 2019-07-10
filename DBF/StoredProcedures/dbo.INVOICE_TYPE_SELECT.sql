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

CREATE PROCEDURE [dbo].[INVOICE_TYPE_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT INT_ID, INT_NAME, INT_SALE, INT_BUY
	FROM 
		dbo.InvoiceTypeTable 
	WHERE INT_ACTIVE = ISNULL(@active, INT_ACTIVE)
END



