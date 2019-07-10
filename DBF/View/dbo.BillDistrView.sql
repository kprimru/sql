USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BillDistrView]
AS
SELECT     
		BL_ID, BL_ID_CLIENT, PR_ID, PR_DATE,
		BD_ID, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE, BD_DATE,
		TX_ID, TX_NAME, TX_PERCENT, TX_CAPTION,
		DIS_ID, DIS_STR, DIS_NUM, DIS_COMP_NUM, HST_ID, SYS_ORDER, SO_NAME, SO_ID
	FROM         
		dbo.BillTable INNER JOIN
        dbo.BillDistrTable ON BL_ID = BD_ID_BILL INNER JOIN
		dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
        dbo.TaxTable ON BD_ID_TAX = TX_ID INNER JOIN
        dbo.DistrView ON DIS_ID = BD_ID_DISTR INNER JOIN
		dbo.SaleObjectTable ON SYS_ID_SO = SO_ID
