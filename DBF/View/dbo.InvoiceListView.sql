USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[InvoiceListView]
AS
SELECT 
	INS_ID, INS_DATE, INS_NUM,
	(CONVERT(VARCHAR(10), INS_NUM) + '/' + INS_NUM_YEAR) AS INS_FULL_NUM,
	CL_ID, CL_PSEDO, INS_INCOME_DATE, INT_NAME,
	CONVERT(MONEY, ISNULL(SUM(INR_SUM*ISNULL(INR_COUNT,1)), 0)) AS INS_PRICE,
	CONVERT(MONEY, ISNULL(SUM(INR_SNDS), 0)) AS INS_TAX_PRICE,
	CONVERT(MONEY, ISNULL(SUM(INR_SALL), 0)) AS INS_TOTAL_PRICE, 
	ORG_PSEDO,
	INS_DOC_STRING
FROM 
	dbo.InvoiceSaleTable WITH(INDEX=IX_InvoiceSaleTable__INS_DATE) INNER JOIN
	dbo.ClientTable ON CL_ID = INS_ID_CLIENT INNER JOIN
	dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE INNER JOIN
	dbo.OrganizationTable ON ORG_ID = INS_ID_ORG LEFT OUTER JOIN
	dbo.InvoiceRowTable WITH(INDEX=IX_InvoiceRowTable) ON INR_ID_INVOICE = INS_ID
GROUP BY INS_ID, INS_DATE, INS_NUM,
	(CONVERT(VARCHAR(10), INS_NUM) + '/' + INS_NUM_YEAR),
	CL_ID, CL_PSEDO, INS_INCOME_DATE, INT_NAME, ORG_PSEDO, INS_DOC_STRING