﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[BillIXView]
WITH SCHEMABINDING
AS
	SELECT BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, PR_DATE, SUM(BD_TOTAL_PRICE) AS BD_TOTAL_PRICE, COUNT_BIG(*) AS BD_CNT
	FROM dbo.BillDistrTable
	INNER JOIN dbo.BillTable ON BD_ID_BILL = BL_ID
	INNER JOIN dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
	GROUP BY BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, PR_DATE
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.BillIXView(BL_ID_CLIENT,BD_ID_DISTR,BL_ID_PERIOD)] ON [dbo].[BillIXView] ([BL_ID_CLIENT] ASC, [BD_ID_DISTR] ASC, [BL_ID_PERIOD] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UC_dbo.BillIXView(BL_ID_CLIENT,BD_ID_DISTR,PR_DATE)] ON [dbo].[BillIXView] ([BL_ID_CLIENT] ASC, [BD_ID_DISTR] ASC, [PR_DATE] ASC);
GO
