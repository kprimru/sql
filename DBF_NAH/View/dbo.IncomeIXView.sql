USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[IncomeIXView]
WITH SCHEMABINDING
AS
	SELECT IN_ID_CLIENT, ID_ID_PERIOD, ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE, COUNT_BIG(*) AS ID_CNT
	FROM
		dbo.IncomeDistrTable INNER JOIN
        dbo.IncomeTable	ON ID_ID_INCOME = IN_ID
	GROUP BY IN_ID_CLIENT, ID_ID_PERIOD, ID_ID_DISTRGO