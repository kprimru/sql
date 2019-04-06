USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Salary].[SalaryConditionAll] 
--WITH SCHEMABINDING
AS
	SELECT 
		SC_ID_MASTER, SC_ID, 		
		SC_WEIGHT, SC_VALUE, SC_DATE, SC_END, SC_REF,
		PT_ID, PT_ID_MASTER, PT_NAME		
	FROM 
		Salary.SalaryConditionDetail	INNER JOIN		
		Personal.PersonalTypeLast	ON	SC_ID_PER_TYPE	=	PT_ID_MASTER