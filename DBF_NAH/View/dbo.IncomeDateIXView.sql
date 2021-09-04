USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[IncomeDateIXView]
WITH SCHEMABINDING
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE, COUNT_BIG(*) AS ID_CNT
	FROM
		dbo.IncomeDistrTable
		INNER JOIN dbo.IncomeTable ON ID_ID_INCOME = IN_ID
		INNER JOIN dbo.PeriodTable ON PR_ID = ID_ID_PERIOD
		INNER JOIN dbo.DistrTable ON DIS_ID = ID_ID_DISTR
		INNER JOIN dbo.SystemTable ON SYS_ID = DIS_ID_SYSTEM
	GROUP BY SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.IncomeDateIXView(DIS_NUM,PR_DATE,SYS_REG_NAME,DIS_COMP_NUM,IN_DATE)] ON [dbo].[IncomeDateIXView] ([DIS_NUM] ASC, [PR_DATE] ASC, [SYS_REG_NAME] ASC, [DIS_COMP_NUM] ASC, [IN_DATE] ASC);
GO
