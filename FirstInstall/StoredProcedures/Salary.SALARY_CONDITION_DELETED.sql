﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SALARY_CONDITION_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Salary].[SalaryConditionDeleted]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Salary].[SALARY_CONDITION_DELETED] TO rl_salary_condition_r;
GO
