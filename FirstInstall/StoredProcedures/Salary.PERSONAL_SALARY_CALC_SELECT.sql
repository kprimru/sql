USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_CALC_SELECT]
	@PER_ID	UNIQUEIDENTIFIER,
	@PR_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ISNULL((
				SELECT PDS_VALUE
				FROM Personal.PersonalDefaultSalary
				WHERE PDS_ID_PERIOD = @PR_ID
					AND PDS_ID_PERSONAL = @PER_ID
			), 0) AS SC_VALUE
END
GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_CALC_SELECT] TO rl_salary_w;
GO
