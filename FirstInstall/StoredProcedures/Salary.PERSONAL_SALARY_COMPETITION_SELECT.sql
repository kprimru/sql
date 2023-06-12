﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[PERSONAL_SALARY_COMPETITION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[PERSONAL_SALARY_COMPETITION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_COMPETITION_SELECT]
	@PS_ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CNT INT
	DECLARE @HLF_ID	UNIQUEIDENTIFIER

	SELECT @CNT = PS_BOOK_COUNT
	FROM Salary.PersonalSalaryView
	WHERE PS_ID = @PS_ID

	SELECT TOP 1 @HLF_ID = IB_ID_HALF
	FROM
		Income.IncomeBook INNER JOIN
		Salary.PersonalSalaryBook ON PSB_ID_IB = IB_ID INNER JOIN
		Salary.PersonalSalary ON PS_ID = PSB_ID_MASTER

	SELECT CP_ID, CP_ID_MASTER, CP_NAME, CP_COUNT, CP_BONUS, HLF_NAME, CP_DATE, CP_END
	FROM
		Book.CompetitionActive
	WHERE HLF_ID_MASTER = @HLF_ID
		AND CP_COUNT <= @CNT
END
GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_COMPETITION_SELECT] TO rl_salary_w;
GO
