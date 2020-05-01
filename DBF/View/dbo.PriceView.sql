USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[PriceView]
AS
	SELECT
		PR_DATE, PS_PRICE, SYS_SHORT_NAME, SYS_ORDER, PT_NAME,
		PR_ID, PS_ID, PT_ID, SYS_ID
	FROM
		dbo.PeriodTable INNER JOIN
		dbo.PriceSystemTable ON PR_ID = PS_ID_PERIOD INNER JOIN
		dbo.PriceTypeTable ON PS_ID_TYPE = PT_ID INNER JOIN
		dbo.SystemTable ON PS_ID_SYSTEM = SYS_ID
