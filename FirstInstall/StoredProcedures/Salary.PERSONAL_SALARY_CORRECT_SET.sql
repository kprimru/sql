USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_CORRECT_SET]
	@PS_ID	UNIQUEIDENTIFIER,
	@SUM	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_SALARY', @PS_ID, @OLD OUTPUT

	UPDATE	Salary.PersonalSalary
	SET		PS_CORRECT	=	@SUM
	WHERE	PS_ID		=	@PS_ID

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_SALARY', @PS_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL_SALARY', '������������� �����', @PS_ID, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_CORRECT_SET] TO rl_salary_w;
GO