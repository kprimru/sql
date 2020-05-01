USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Income].[IncomeDetailView]
--WITH SCHEMABINDING
AS
	SELECT
		ID_ID, ID_ID_INCOME AS IN_ID, ID_COUNT,
		ID_DEL_SUM, CAST (ROUND((ID_DEL_SUM / 1.18), 2) AS MONEY) AS ID_DEL_SUM_NDS, ID_DEL_PRICE, CAST(ROUND((ID_DEL_PRICE / 1.18), 2) AS MONEY) AS ID_DEL_PRICE_NDS, ID_DEL_DISCOUNT,
		ID_ACTION, ID_RESTORE, ID_EXCHANGE, ID_CALC,
		ID_FULL_DATE, ID_MON_STR, ID_SALARY, CAST (ROUND((ID_SALARY / 1.18), 2) AS MONEY) AS ID_SALARY_NDS,
		ID_ID_FULL_PAY, ID_ID_FIRST_MON, ID_MON_CNT, ID_NOTE,
		ID_SUP_PRICE, CAST(ROUND((ID_SUP_PRICE / 1.18), 2) AS MONEY) AS ID_SUP_PRICE_NDS, ID_SUP_DISCOUNT,
		ID_SUP_MONTH, CAST(ROUND((ID_SUP_MONTH / 1.18), 2) AS MONEY) AS ID_SUP_MONTH_NDS, ID_PREPAY,
		ID_SUP_CONTRACT, ID_SUP_DATE,
		ID_LOCK, ID_COMMENT, ID_REPAY,
		SYS_ID, SYS_ID_MASTER, SYS_SHORT, SYS_ORDER,
		DT_ID, DT_ID_MASTER, DT_NAME, DT_SHORT,
		NT_ID, NT_ID_MASTER, NT_NAME,
		TT_ID, TT_ID_MASTER, TT_NAME, TT_SHORT,
		CASE
			WHEN TT_REG = 0 THEN NT_NAME
			ELSE TT_SHORT
		END AS NT_NEW_NAME, ID_MAIN, ID_COLOR,
		ID_INSTALL
	FROM
		Income.IncomeDetail											INNER JOIN
		Distr.SystemDetail		ON	SYS_ID_MASTER	= ID_ID_SYSTEM	INNER JOIN
		Distr.DistrTypeDetail	ON	DT_ID_MASTER	= ID_ID_TYPE	INNER JOIN
		Distr.NetTypeDetail		ON	NT_ID_MASTER	= ID_ID_NET		INNER JOIN
		Distr.TechTypeDetail	ON	TT_ID_MASTER	= ID_ID_TECH
	WHERE SYS_REF IN (1, 3) AND DT_REF IN (1, 3) AND NT_REF IN (1, 3) AND TT_REF IN (1, 3)
	