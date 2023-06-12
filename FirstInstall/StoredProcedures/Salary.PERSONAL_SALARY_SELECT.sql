﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[PERSONAL_SALARY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[PERSONAL_SALARY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_SELECT]
	@PR_ID	UNIQUEIDENTIFIER,
	@VD_ID	UNIQUEIDENTIFIER,
	@PAY	BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		/*
		PS_ID,
		PER_ID, PER_ID_MASTER, PER_NAME,
		PS_DATE,
		PR_ID, PR_ID_MASTER, PR_NAME, 
		PS_SALARY, PS_CORRECT, PS_COMMENT
		*/

		PS_ID,
		PER_ID_MASTER, PER_NAME, 
		--PS_DATE,
		PR_ID_MASTER, PR_NAME,
		PR_PAY_ID_MASTER, PR_PAY_NAME,
		PS_SALARY, PSD_TOTAL, PSB_TOTAL, PSB_DELIVERY, PS_CORRECT, PS_DEBT,
		PS_BOOK_COUNT,
		PS_BOOK_NORM,
		CP_ID_MASTER, CP_NAME, PS_BOOK_BONUS,
		PS_COMMENT, PS_LOCK
	FROM
		Salary.PersonalSalaryView
	WHERE	(PR_ID_MASTER = @PR_ID OR @PR_ID IS NULL)
		AND (VD_ID_MASTER = @VD_ID OR @VD_ID IS NULL)
		AND (PS_PAYED = @PAY OR @PAY IS NULL)
	ORDER BY PER_NAME
END
GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_SELECT] TO rl_salary_r;
GO
