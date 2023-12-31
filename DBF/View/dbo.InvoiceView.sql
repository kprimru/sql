USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[InvoiceView]
AS
SELECT	INS_ID,
		INS_ID_TYPE,
		INS_ID_ORG,
		ORG_PSEDO,

		INS_DATE,
		INS_NUM,
		INS_NUM_YEAR,

		/*
		INS_ID_INCOME,
		IN_DATE,
		IN_PAY_NUM,
		*/

		INS_ID_CLIENT,
		CL_SHORT_NAME,
		CL_INN,
		CA_STR,

		INS_STORNO,
		INS_COMMENT,

		INS_DOC_STRING,
		(SELECT SUM(INR_SALL) FROM dbo.InvoiceRowTable WHERE INR_ID_INVOICE=INS_ID) AS IF_TOTAL_PRICE,
		INT_NAME
FROM
		dbo.InvoiceSaleTable	a									LEFT JOIN
		--IncomeTable			b	ON	a.INS_ID_INCOME=b.IN_ID		LEFT JOIN
		dbo.ClientView			c	ON	a.INS_ID_CLIENT=c.CL_ID		LEFT JOIN --INNER JOIN
		dbo.ClientAddressView	d	ON	c.CL_ID=d.CA_ID_CLIENT
									and d.CA_ID_TYPE = 1		LEFT JOIN
		dbo.OrganizationTable	e	ON	a.INS_ID_ORG=e.ORG_ID		LEFT JOIN
		dbo.InvoiceTypeTable	f	ON	a.INS_ID_TYPE = f.INT_ID
GO
