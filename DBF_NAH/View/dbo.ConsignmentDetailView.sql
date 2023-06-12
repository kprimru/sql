USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ConsignmentDetailView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ConsignmentDetailView]  AS SELECT 1')
GO
ALTER VIEW dbo.ConsignmentDetailView
AS
SELECT     dbo.ConsignmentDetailTable.CSD_ID, dbo.ConsignmentTable.CSG_ID, dbo.ConsignmentTable.CSG_ID_ORG, dbo.ConsignmentTable.CSG_ID_CLIENT,
                      dbo.ConsignmentTable.CSG_CONSIGN_NAME, dbo.ConsignmentTable.CSG_NUM, dbo.ConsignmentTable.CSG_DATE,
                      dbo.ConsignmentTable.CSG_ID_INVOICE, dbo.ConsignmentDetailTable.CSD_ID_DISTR, dbo.ConsignmentDetailTable.CSD_NUM,
                      dbo.ConsignmentDetailTable.CSD_PRICE, dbo.ConsignmentDetailTable.CSD_TAX_PRICE, dbo.ConsignmentDetailTable.CSD_TOTAL_PRICE
FROM         dbo.ConsignmentTable INNER JOIN
                      dbo.ConsignmentDetailTable ON dbo.ConsignmentTable.CSG_ID = dbo.ConsignmentDetailTable.CSD_ID_CONS
GO
