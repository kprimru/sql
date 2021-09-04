USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ActAllIXView]
WITH SCHEMABINDING
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE, ACT_DATE, COUNT_BIG(*) AS ID_CNT
	FROM
		dbo.ActDistrTable
		INNER JOIN dbo.ActTable ON AD_ID_ACT = ACT_ID
		INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
		INNER JOIN dbo.DistrTable ON DIS_ID = AD_ID_DISTR
		INNER JOIN dbo.SystemTable ON SYS_ID = DIS_ID_SYSTEM
	GROUP BY SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE, ACT_DATE
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ActAllIXView(DIS_NUM,PR_DATE,SYS_REG_NAME,DIS_COMP_NUM,AD_TOTAL_PRICE,ACT_DATE)] ON [dbo].[ActAllIXView] ([DIS_NUM] ASC, [PR_DATE] ASC, [SYS_REG_NAME] ASC, [DIS_COMP_NUM] ASC, [AD_TOTAL_PRICE] ASC, [ACT_DATE] ASC);
GO
