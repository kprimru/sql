USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DBFDistrLastPayView]
AS
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, LAST_ACT, LAST_PAY_MON, LAST_BILL_SUM, LAST_INCOME_SUM, NEXT_MONTH, LAST_BILL_SUM - LAST_INCOME_SUM AS PAY_DELTA
	FROM
	(
		SELECT
			SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, LAST_ACT, LAST_PAY_MON,
			ISNULL(
				(
					SELECT BD_TOTAL_PRICE
					FROM dbo.DBFBill AS B
					WHERE	B.SYS_REG_NAME = D.SYS_REG_NAME
						AND B.DIS_NUM = D.DIS_NUM
						AND B.DIS_COMP_NUM = D.DIS_COMP_NUM
						AND B.PR_DATE = DATEADD(MONTH, 1, D.LAST_ACT)
				), 0) AS LAST_BILL_SUM,
			ISNULL(
				(
					SELECT SUM(ID_PRICE)
					FROM dbo.DBFIncome AS I
					WHERE	I.SYS_REG_NAME = D.SYS_REG_NAME
						AND I.DIS_NUM = D.DIS_NUM
						AND I.DIS_COMP_NUM = D.DIS_COMP_NUM
						AND I.PR_DATE = DATEADD(MONTH, 1, D.LAST_ACT)
				), 0) AS LAST_INCOME_SUM,
			DATEADD(MONTH, 1, LAST_ACT) AS NEXT_MONTH
		FROM
		(
			SELECT
				SYS_REG_NAME	= D.SystemBaseName,
				DIS_NUM			= D.DISTR,
				DIS_COMP_NUM	= D.COMP,
				LAST_ACT		= A.LAST_ACT,
				LAST_PAY_MON	= B.LAST_PAY_MON
			FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
			OUTER APPLY
			(
				SELECT TOP (1)
					[LAST_ACT] = PR_DATE
				FROM dbo.DBFAct AS A
				WHERE	A.SYS_REG_NAME = D.SystemBaseName
					AND A.DIS_NUM = D.DISTR
					AND A.DIS_COMP_NUM = D.COMP
				ORDER BY PR_DATE DESC
			) AS A
			OUTER APPLY
			(
				SELECT TOP (1)
					[LAST_PAY_MON] = PR_DATE
				FROM dbo.DBFBill AS B
				WHERE	B.SYS_REG_NAME = D.SystemBaseName
					AND B.DIS_NUM = D.DISTR
					AND B.DIS_COMP_NUM = D.COMP
					AND B.BD_TOTAL_PRICE =
						(
							SELECT SUM(ID_PRICE)
							FROM dbo.DBFIncome AS I
							WHERE	B.SYS_REG_NAME = I.SYS_REG_NAME
								AND B.DIS_NUM = I.DIS_NUM
								AND B.DIS_COMP_NUM = I.DIS_COMP_NUM
								AND B.PR_DATE = I.PR_DATE
						)
				ORDER BY PR_DATE DESC
			) AS B
		) AS D
	) AS D
GO
