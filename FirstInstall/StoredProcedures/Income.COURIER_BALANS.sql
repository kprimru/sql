﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[COURIER_BALANS]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@PT_ID	UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		PER_NAME, IN_DATE, CL_NAME, a.SYS_SHORT, a.NT_NEW_NAME,
		ID_COUNT * STW_WEIGHT * NT_COEF AS WEIGHT,
		ID_COMMENT, ID_COUNT
	FROM
		Personal.PersonalActive INNER JOIN
		Income.IncomePersonal ON IP_ID_PERSONAL = PER_ID_MASTER INNER JOIN
		Income.IncomeFullView a ON ID_ID = IP_ID_INCOME INNER JOIN
		Distr.SystemActive b ON a.SYS_ID_MASTER = b.SYS_ID_MASTER INNER JOIN
		Distr.NetTypeActive c ON c.NT_ID_MASTER = a.NT_ID_MASTER INNER JOIN
		Distr.SystemTypeWeight d ON d.STW_ID_SYSTEM = a.SYS_ID_MASTER AND d.STW_ID_TYPE = a.DT_ID_MASTER
	WHERE IN_DATE BETWEEN @BEGIN AND @END
		AND ID_RESTORE = 0 AND ID_EXCHANGE = 0 AND ID_REPAYED = 0
		AND (PER_ID_TYPE = @PT_ID OR @PT_ID IS NULL)
	ORDER BY PER_NAME, IN_DATE, CL_NAME
END
GO
GRANT EXECUTE ON [Income].[COURIER_BALANS] TO rl_courier_balans;
GO
