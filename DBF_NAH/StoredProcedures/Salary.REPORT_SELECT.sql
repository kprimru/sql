USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[REPORT_SELECT]
	@PERIOD	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	/*
	SELECT
		ID, PR_NAME, COUR_NAME, COUR_BASE, TO_ID, CL_ID, CL_PSEDO, CL_BASE, CLT_ID,
		CLT_NAME, SYS_COUNT, CL_SUM, TO_COUNT PRICE, TOTAL_PRICE, COUR_MIN, COUR_MAX,
		COUR_PERCENT, COEF, CL_PAY, CL_ACT_KGS, TOTAL, COUR_COUNT, CL_TERR
	FROM
		asdasd
	*/
END

GO
GRANT EXECUTE ON [Salary].[REPORT_SELECT] TO rl_courier_pay;
GO