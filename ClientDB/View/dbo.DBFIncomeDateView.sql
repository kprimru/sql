USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DBFIncomeDateView]
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE
	FROM dbo.DBFIncomeDate
GO
