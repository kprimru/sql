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

CREATE PROCEDURE [dbo].[INVOICE_LIST_DELETE]
	@id VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @list TABLE (ID INT)
	INSERT INTO @list SELECT * FROM dbo.GET_TABLE_FROM_LIST(@id, ',')

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT b.INS_ID_CLIENT, b.INS_ID, 'INVOICE', 'Удаление с/ф', b.INS_DATA
		FROM 
			@list a
			INNER JOIN dbo.InvoiceProtocolView b ON a.ID = b.INS_ID

	DELETE 
	FROM dbo.InvoiceRowTable 
	WHERE INR_ID_INVOICE IN 
		(
			SELECT ID
			FROM @list
		)

	UPDATE dbo.IncomeTable
	SET IN_ID_INVOICE = NULL
	WHERE IN_ID_INVOICE IN
		(
			SELECT ID
			FROM @list
		)

	UPDATE dbo.ActTable
	SET ACT_ID_INVOICE = NULL
	WHERE ACT_ID_INVOICE IN
		(
			SELECT ID
			FROM @list
		)

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_INVOICE = NULL
	WHERE CSG_ID_INVOICE IN
		(
			SELECT ID
			FROM @list
		)

	UPDATE dbo.PrimaryPayTable
	SET PRP_ID_INVOICE = NULL
	WHERE PRP_ID_INVOICE IN
		(
			SELECT ID
			FROM @list
		)

	DELETE 
	FROM dbo.BookSaleDetail
	WHERE ID_SALE IN
		(
			SELECT ID
			FROM dbo.BookSale
			WHERE ID_INVOICE IN
				(
					SELECT ID
					FROM @list
				)
		)
		
	DELETE FROM dbo.BookPurchase
	WHERE ID_INVOICE IN
		(
			SELECT ID
			FROM @list
		) OR ID_AVANS IN
		(
			SELECT ID
			FROM @list
		)
		
	DELETE 
	FROM dbo.BookPurchaseDetail
	WHERE ID_PURCHASE IN
		(
			SELECT ID
			FROM dbo.BookPurchase
			WHERE ID_INVOICE IN
				(
					SELECT ID
					FROM @list
				) OR
				ID_AVANS IN
				(
					SELECT ID
					FROM @list
				)
		)
		
	DELETE FROM dbo.BookSale
	WHERE ID_INVOICE IN
		(
			SELECT ID
			FROM @list
		)

	DELETE 
	FROM dbo.InvoiceSaleTable
	WHERE INS_ID IN
		(
			SELECT ID
			FROM @list
		)
		
	
END
