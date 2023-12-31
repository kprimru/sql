USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [Income].[IncomeFullView]
--WITH SCHEMABINDING
AS
SELECT
		a.IN_ID, IN_DATE, IN_PAY,
		VD_ID, VD_ID_MASTER, VD_NAME,
		CL_ID, CL_ID_MASTER, CL_NAME, 
		SYS_ID, SYS_ID_MASTER, SYS_SHORT, SYS_ORDER, SYS_MAIN,
		DT_ID, DT_ID_MASTER, DT_NAME, DT_SHORT,
		NT_ID, NT_ID_MASTER, NT_NAME,
		TT_ID, TT_ID_MASTER, TT_NAME, TT_SHORT,
		ID_ID, ID_COUNT, ID_CALC,
		ID_DEL_SUM, ID_DEL_SUM_NDS, ID_DEL_PRICE, ID_DEL_PRICE_NDS, ID_DEL_DISCOUNT,
		ID_ACTION, ID_RESTORE, ID_EXCHANGE, ID_FULL_DATE,
		PR_FIRST_ID, PR_FIRST_ID_MASTER, PR_FIRST_NAME, ID_MON_CNT,
		PR_FULL_ID, PR_FULL_ID_MASTER, PR_FULL_NAME, ID_SALARY, ID_SALARY_NDS,
		ID_SUP_PRICE, ID_SUP_PRICE_NDS, ID_SUP_DISCOUNT,
		ID_SUP_MONTH, ID_SUP_MONTH_NDS, ID_PREPAY,
		ID_SUP_CONTRACT, ID_SUP_DATE, ID_MON_STR,
		NT_NEW_NAME,
		ID_LOCK, ID_COMMENT, ID_REPAY, ID_REPAYED, ID_NOTE, ID_MAIN, ID_COLOR, ID_ORANGE,
		REVERSE(STUFF(REVERSE((
			SELECT PER_NAME +
						'(' +
							CONVERT(VARCHAR(20), CONVERT(DECIMAL(8, 2), IP_PERCENT)) +
							CASE
								WHEN ISNULL(IP_PERCENT2, 0) <> 0 THEN '/' + CONVERT(VARCHAR(20), CONVERT(DECIMAL(8, 2), IP_PERCENT2))
								ELSE ''
							END +
						')'
						+ ','
			FROM Income.IncomePersonalView c WITH(NOEXPAND)
			WHERE c.ID_ID = b.ID_ID
			ORDER BY PER_NAME FOR XML PATH('')
		)),1,1,'')) AS ID_PERSONAL,
		(
			SELECT TOP 1 ID_ID
			FROM
				Income.IncomeDetail z INNER JOIN
				Income.Incomes y ON z.ID_ID_INCOME = y.IN_ID INNER JOIN
				Income.Incomes x ON x.IN_ID = b.IN_ID
			WHERE y.IN_ID = x.IN_ID_INCOME
				AND b.SYS_ID_MASTER = z.ID_ID_SYSTEM
				AND b.DT_ID_MASTER = z.ID_ID_TYPE
				AND b.NT_ID_MASTER = z.ID_ID_NET
				AND b.TT_ID_MASTER = z.ID_ID_TECH
		) AS ID_ID_MASTER
	FROM
		Income.IncomeMasterView a WITH(NOEXPAND) INNER JOIN
		Income.IncomeDetailFullView b ON a.IN_ID = b.IN_ID
GO
