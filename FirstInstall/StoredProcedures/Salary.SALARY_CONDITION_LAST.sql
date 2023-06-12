﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SALARY_CONDITION_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SALARY_CONDITION_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[SALARY_CONDITION_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(SCMS_LAST)
	FROM	Salary.SalaryCondition
END
GO
GRANT EXECUTE ON [Salary].[SALARY_CONDITION_LAST] TO rl_salary_condition_r;
GO
