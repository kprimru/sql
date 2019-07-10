USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DistrLastPayView]
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, LAST_ACT, LAST_PAY_MON, LAST_BILL_SUM, LAST_INCOME_SUM, NEXT_MONTH, LAST_BILL_SUM - LAST_INCOME_SUM AS PAY_DELTA
	FROM
		(
			SELECT
				SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, LAST_ACT, LAST_PAY_MON,
				ISNULL((
					SELECT BD_TOTAL_PRICE
					FROM 
						dbo.BillIXView WITH(NOEXPAND)
						INNER JOIN dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
					WHERE BL_ID_CLIENT = CL_ID
						AND BD_ID_DISTR = DIS_ID
						AND PR_DATE = DATEADD(MONTH, 1, LAST_ACT)
				), 0) AS LAST_BILL_SUM,
				ISNULL((
					SELECT SUM(ID_PRICE)
					FROM 
						dbo.IncomeIXView WITH(NOEXPAND)
						INNER JOIN dbo.PeriodTable ON PR_ID = ID_ID_PERIOD
					WHERE IN_ID_CLIENT = CL_ID
						AND ID_ID_DISTR = DIS_ID
						AND PR_DATE = DATEADD(MONTH, 1, LAST_ACT)
				), 0) AS LAST_INCOME_SUM,
				DATEADD(MONTH, 1, LAST_ACT) AS NEXT_MONTH
			FROM
				(
					SELECT 
						CL_ID, DIS_ID, SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, 
						(
							SELECT MAX(PR_DATE)
							FROM 
								dbo.PeriodTable INNER JOIN
								dbo.ActIXView WITH(NOEXPAND) ON AD_ID_PERIOD = PR_ID
							WHERE ACT_ID_CLIENT = CL_ID 
								AND AD_ID_DISTR = DIS_ID
						) AS LAST_ACT,
						(
							SELECT MAX(PR_DATE)
							FROM 
								dbo.PeriodTable INNER JOIN
								dbo.BillIXView WITH(NOEXPAND) ON BL_ID_PERIOD = PR_ID
							WHERE BL_ID_CLIENT = CL_ID 
								AND BD_ID_DISTR = DIS_ID
								AND BD_TOTAL_PRICE = 
									(
										SELECT SUM(ID_PRICE)
										FROM dbo.IncomeIXView WITH(NOEXPAND)
										WHERE ID_ID_DISTR = BD_ID_DISTR 
											AND ID_ID_PERIOD = BL_ID_PERIOD 
											AND IN_ID_CLIENT = BL_ID_CLIENT
									)
						) AS LAST_PAY_MON
					FROM 
						dbo.DistrView a
						INNER JOIN dbo.ClientDistrTable b ON a.DIS_ID = b.CD_ID_DISTR
						INNER JOIN dbo.ClientTable c ON c.CL_ID = CD_ID_CLIENT
					WHERE SYS_REG_NAME <> '-'
				) AS a
		) AS a