USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBFIncomeView]
AS	
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE
	--FROM [PC275-SQL\DELTA].DBF.dbo.IncomeAllIXView WITH(NOEXPAND)
	FROM dbo.DBFIncome