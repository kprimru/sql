USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.SystemDocCountView
AS
SELECT     TOP (100) PERCENT dbo.PeriodTable.PR_DATE, dbo.PriceSystemHistoryTable.PSH_DOC_COUNT, dbo.SystemTable.SYS_SHORT_NAME
FROM         dbo.SystemTable INNER JOIN
                      dbo.PeriodTable INNER JOIN
                      dbo.PriceSystemHistoryTable ON dbo.PeriodTable.PR_ID = dbo.PriceSystemHistoryTable.PSH_ID_PERIOD ON
                      dbo.SystemTable.SYS_ID = dbo.PriceSystemHistoryTable.PSH_ID_SYSTEM
ORDER BY dbo.PeriodTable.PR_DATE, dbo.SystemTable.SYS_SHORT_NAME
GO
