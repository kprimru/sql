﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[DistrTotalPriceView]
AS
SELECT
		CD_ID_CLIENT, DSS_REPORT, a.DIS_ID, PR_ID, PR_DATE, SO_ID,
		CAST(ROUND(DIS_PRICE * (1 + ISNULL(TX_PERCENT/ 100, 0)), 2) AS MONEY) AS DIS_TOTAL_PRICE,
		a.SYS_ORDER
	FROM
		dbo.DistrPriceView a INNER JOIN
		dbo.DistrView b WITH(NOEXPAND) ON a.DIS_ID = b.DIS_ID INNER JOIN
		dbo.SaleObjectTable ON SO_ID = a.SYS_ID_SO INNER JOIN
		dbo.TaxTable ON TX_ID = SO_ID_TAX
GO
