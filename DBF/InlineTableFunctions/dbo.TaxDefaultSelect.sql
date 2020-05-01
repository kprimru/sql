USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[TaxDefaultSelect]
(
	@Date SMALLDATETIME
)
RETURNS TABLE
AS
RETURN
(
	SELECT TX_ID, TX_CAPTION, TX_PERCENT, TX_TOTAL_RATE = (((100)+TX_PERCENT)/(100)) , TX_TAX_RATE = (TX_PERCENT/(100))
	FROM dbo.TaxTable
	WHERE TX_PERCENT = 18
		AND (@DATE IS NULL OR @DATE < '20190101')

	UNION ALL

	SELECT TX_ID, TX_CAPTION, TX_PERCENT, TX_TOTAL_RATE = (((100)+TX_PERCENT)/(100)) , TX_TAX_RATE = (TX_PERCENT/(100))
	FROM dbo.TaxTable
	WHERE TX_PERCENT = 20
		AND (@DATE >= '20190101')
)
