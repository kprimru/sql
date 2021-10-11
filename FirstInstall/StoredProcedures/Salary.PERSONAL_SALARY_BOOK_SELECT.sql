USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_BOOK_SELECT]
	@PS_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	*
	FROM	Salary.PersonalSalaryBookView
	WHERE	PS_ID	=	@PS_ID
END
GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_BOOK_SELECT] TO rl_salary_r;
GO
