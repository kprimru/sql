USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBFPriceView]
AS	
	SELECT SYS_REG_NAME, PR_DATE, PT_NAME, PS_PRICE
	FROM [PC275-SQL\DELTA].[DBF].[dbo].[PriceExportView]
	WHERE SYS_REG_NAME NOT IN ('-', '--')