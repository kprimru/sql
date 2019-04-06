USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  24.03.2009
Описание:		все счета-фактуры клиента
*/

CREATE PROCEDURE [dbo].[CLIENT_INVOICE_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	
		INS_ID, INS_DATE, (CONVERT(VARCHAR(20), INS_NUM) + '/' + INS_NUM_YEAR) AS INS_FULL_NUM,
		ORG_PSEDO, 
		(
			SELECT SUM(INR_SALL) 
			FROM dbo.InvoiceRowTable 
			WHERE INR_ID_INVOICE = INS_ID
		) IF_TOTAL_PRICE, INT_NAME, ACT_ID,
		(
			SELECT SUM(S_ALL)
			FROM 
				dbo.BookSale z
				INNER JOIN dbo.BookSaleDetail y ON z.ID = y.ID_SALE
			WHERE INS_ID = ID_INVOICE
		) AS SALE_SUM,
		CONVERT(VARCHAR(500), (
			SELECT 'Аванс: ' + CONVERT(VARCHAR(20), ID_AVANS) + ' , Реализ: ' + CONVERT(VARCHAR(20), ID_INVOICE) + '; Сумма: ' + dbo.MoneyFormat(S_ALL) + ' ||  '
			FROM
				( 
					SELECT DISTINCT ID_INVOICE, ID_AVANS, SUM(S_ALL) AS S_ALL
					FROM
						dbo.BookPurchase z
						INNER JOIN dbo.BookPurchaseDetail y ON z.ID = y.ID_PURCHASE
					WHERE z.ID_AVANS = INS_ID OR z.ID_INVOICE = INS_ID
					GROUP BY ID_INVOICE, ID_AVANS
				) AS o_O
			ORDER BY ID_INVOICE FOR XML PATH('')
		)) AS PURCHASE_SUM
	FROM 
		dbo.InvoiceSaleTable
		INNER JOIN dbo.ClientTable ON INS_ID_CLIENT = CL_ID
		INNER JOIN dbo.OrganizationTable ON ORG_ID = INS_ID_ORG
		LEFT OUTER JOIN dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
		LEFT OUTER JOIN dbo.ActTable ON ACT_ID_INVOICE = INS_ID
	WHERE INS_ID_CLIENT = @clientid
	ORDER BY INS_DATE DESC, INS_NUM

END
















