USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW dbo.SystemView
AS
SELECT     dbo.SystemTable.SYS_ID, dbo.SystemTable.SYS_PREFIX, dbo.SystemTable.SYS_NAME, dbo.SystemTable.SYS_SHORT_NAME,
                      dbo.SystemTable.SYS_PSEDO, dbo.SystemTable.SYS_REG_NAME, dbo.SystemTable.SYS_REPORT, dbo.SystemTable.SYS_MAIN,
                      dbo.HostTable.HST_NAME, dbo.HostTable.HST_REG_NAME, dbo.SaleObjectTable.SO_ID, dbo.SaleObjectTable.SO_NAME
FROM         dbo.SystemTable INNER JOIN
                      dbo.HostTable ON dbo.SystemTable.SYS_ID_HOST = dbo.HostTable.HST_ID INNER JOIN
                      dbo.SaleObjectTable ON dbo.SystemTable.SYS_ID_SO = dbo.SaleObjectTable.SO_ID
GO
