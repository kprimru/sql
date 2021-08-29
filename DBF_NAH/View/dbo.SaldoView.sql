USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[SaldoView]
AS
SELECT
		SL_ID, SL_ID_CLIENT, SL_ID_DISTR, SL_DATE, SL_REST, SL_BEZ_NDS, SL_TP,
		ID_ID, ID_PRICE,
		AD_ID, AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
		BD_ID, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
		CSD_ID, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE
	FROM
		dbo.SaldoTable AS a LEFT OUTER JOIN
		dbo.ActDistrView AS b ON a.SL_ID_ACT_DIS = b.AD_ID LEFT OUTER JOIN
		dbo.BillDistrView AS c ON a.SL_ID_BILL_DIS = c.BD_ID LEFT OUTER JOIN
		dbo.IncomeDistrView AS d ON a.SL_ID_IN_DIS = d.ID_ID LEFT OUTER JOIN
		dbo.ConsignmentDetailView AS e ON a.SL_ID_CONSIG_DIS = e.CSD_ID
GO