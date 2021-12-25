﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[BillAllIXView]
WITH SCHEMABINDING
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, SUM(BD_TOTAL_PRICE) AS BD_TOTAL_PRICE, COUNT_BIG(*) AS CNT
	FROM
		dbo.BillTable a
		INNER JOIN dbo.BillDistrTable b ON a.BL_ID = b.BD_ID_BILL
		INNER JOIN dbo.PeriodTable c ON c.PR_ID = a.BL_ID_PERIOD
		INNER JOIN dbo.DistrTable d ON d.DIS_ID = b.BD_ID_DISTR
		INNER JOIN dbo.SystemTable e ON e.SYS_ID = d.DIS_ID_SYSTEM
	GROUP BY SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.BillAllIXView(DIS_NUM,PR_DATE,SYS_REG_NAME,DIS_COMP_NUM)] ON [dbo].[BillAllIXView] ([DIS_NUM] ASC, [PR_DATE] ASC, [SYS_REG_NAME] ASC, [DIS_COMP_NUM] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BillAllIXView(PR_DATE)+(SYS_REG_NAME,DIS_NUM,DIS_COMP_NUM,BD_TOTAL_PRICE)] ON [dbo].[BillAllIXView] ([PR_DATE] ASC) INCLUDE ([SYS_REG_NAME], [DIS_NUM], [DIS_COMP_NUM], [BD_TOTAL_PRICE]);
GO
