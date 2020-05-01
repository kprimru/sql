USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_SUMMARY_DETAIL_GROUP_SELECT]
	@PR_ID	UNIQUEIDENTIFIER,
	@VD_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT PER_ID_TYPE, PT_NAME
	FROM
		Salary.PersonalSalary	LEFT OUTER JOIN
		Salary.PersonalSalaryDetail ON PSD_ID_MASTER = PS_ID INNER JOIN
		Personal.PersonalLast ON PER_ID_MASTER	=	PS_ID_PERSONAL	LEFT OUTER JOIN
		Income.IncomeFullView	ON ID_ID = PSD_ID_INCOME LEFT OUTER JOIN
		Personal.PersonalTypeActive ON PT_ID_MASTER = PER_ID_TYPE
	WHERE PS_ID_PERIOD = @PR_ID AND PS_ID_VENDOR = @VD_ID
END
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_SUMMARY_DETAIL_GROUP_SELECT] TO rl_salary_w;
GO