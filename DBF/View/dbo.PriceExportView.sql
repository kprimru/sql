﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[PriceExportView]
WITH SCHEMABINDING
AS
	SELECT
		SYS_REG_NAME, PR_DATE, PT_NAME, PS_PRICE
	FROM dbo.PeriodTable
	INNER JOIN dbo.PriceSystemTable ON PR_ID = PS_ID_PERIOD
	INNER JOIN dbo.PriceTypeTable ON PS_ID_TYPE = PT_ID
	INNER JOIN dbo.SystemTable ON PS_ID_SYSTEM = SYS_ID
	WHERE PT_ID = 1

GO
CREATE UNIQUE CLUSTERED INDEX [IX_CLUST] ON [dbo].[PriceExportView] ([SYS_REG_NAME] ASC, [PR_DATE] ASC, [PT_NAME] ASC);
GO
