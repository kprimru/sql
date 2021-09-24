USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_SALARY_SELECT]
	@PR_ID	UNIQUEIDENTIFIER,
	@PT_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		PDS_ID, PER_ID_MASTER, PER_NAME, PDS_VALUE, PDS_COMMENT
	FROM
		Personal.PersonalActive LEFT OUTER JOIN
		Personal.PersonalDefaultSalary ON PDS_ID_PERSONAL = PER_ID_MASTER
									AND PDS_ID_PERIOD = @PR_ID
	WHERE (@PT_ID IS NULL OR PER_ID_TYPE = @PT_ID)

END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_SALARY_SELECT] TO rl_personal_default_salary_r;
GO
