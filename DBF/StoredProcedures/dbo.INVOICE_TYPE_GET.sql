USE [DBF]
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

CREATE PROCEDURE [dbo].[INVOICE_TYPE_GET]
	@intid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT INT_ID, INT_NAME, INT_PSEDO, INT_SALE, INT_BUY, INT_ACTIVE
	FROM 
		dbo.InvoiceTypeTable 
	WHERE INT_ID = @intid
END





