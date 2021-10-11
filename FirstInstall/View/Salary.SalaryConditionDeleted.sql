USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Salary].[SalaryConditionDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		SC_ID_MASTER, SC_ID, 
		SC_WEIGHT, SC_VALUE, SC_DATE, SC_END,
		PT_ID, PT_ID_MASTER, PT_NAME
	FROM
		Salary.SalaryConditionAll a
	WHERE SC_REF = 3GO
