USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[REPORT_ACT_CALC_NEW]
	@periodid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @periodid IS NULL
		SELECT 
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			PR_ID, a.DIS_ID, DIS_STR, PR_DATE, BD_TOTAL_PRICE, 
			ISNULL(
				REVERSE(
					STUFF(
						REVERSE(
									(
										SELECT 
											CONVERT(VARCHAR(20), IN_DATE, 104) + ' (' + 
											CONVERT(VARCHAR(20), IN_PAY_NUM, 104) + ')' + ' /'
										FROM
											(
												SELECT DISTINCT IN_DATE, IN_PAY_NUM
												FROM 
													dbo.IncomeTable INNER JOIN
													dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
												WHERE ID_ID_DISTR = BD_ID_DISTR 
													AND ID_ID_PERIOD = BL_ID_PERIOD
													AND IN_ID_CLIENT = BL_ID_CLIENT
											) AS o_O
										ORDER BY IN_DATE DESC, IN_PAY_NUM FOR XML PATH('')
									)
								)
						, 1, 1, '')), '') AS IN_DATE,
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM dbo.IncomeIXView WITH(NOEXPAND)
					/*
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
					*/
				WHERE ID_ID_DISTR = BD_ID_DISTR 
					AND ID_ID_PERIOD = BL_ID_PERIOD
					AND IN_ID_CLIENT = BL_ID_CLIENT
			), 0) AS BD_PAYED_PRICE,
			(
				SELECT TOP 1 COUR_NAME
				FROM 
					dbo.TOTable INNER JOIN
					dbo.CourierTable ON TO_ID_COUR = COUR_ID
				WHERE TO_ID_CLIENT = CL_ID
				ORDER BY TO_MAIN DESC
			) AS COUR_NAME
		FROM 
			dbo.BillIXVIew WITH(NOEXPAND) INNER JOIN
			/*
			dbo.BillDistrTable INNER JOIN
			*/
			dbo.DistrView a ON a.DIS_ID = BD_ID_DISTR INNER JOIN
			/*
			dbo.BillTable ON BL_ID = BD_ID_BILL INNER JOIN
			*/
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
			dbo.CLientTable ON BL_ID_CLIENT = CL_ID 
		WHERE  
			DOC_PSEDO = 'ACT' AND
			DD_PRINT = 1 AND
			NOT EXISTS
			(
				SELECT *
				FROM dbo.ActIXView WITH(NOEXPAND)
					/*
					dbo.ActTable INNER JOIN
					dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
					*/
				WHERE AD_ID_DISTR = BD_ID_DISTR
					AND BL_ID_PERIOD = AD_ID_PERIOD
					AND BL_ID_CLIENT = ACT_ID_CLIENT
			) AND
			-- неоплаченная сумма счета
			BD_TOTAL_PRICE = 
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM dbo.IncomeIXView WITH(NOEXPAND)
					/*
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
					*/
				WHERE ID_ID_DISTR = BD_ID_DISTR 
					AND ID_ID_PERIOD = BL_ID_PERIOD
					AND IN_ID_CLIENT = BL_ID_CLIENT
			), 0)
		ORDER BY COUR_NAME, CL_PSEDO, SYS_ORDER
	ELSE
		SELECT 
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			PR_ID, a.DIS_ID, DIS_STR, PR_DATE, BD_TOTAL_PRICE, 
			ISNULL(
				REVERSE(
					STUFF(
						REVERSE(
									(
										SELECT 
											CONVERT(VARCHAR(20), IN_DATE, 104) + ' (' + 
											CONVERT(VARCHAR(20), IN_PAY_NUM, 104) + ')' + ' /'
										FROM
											(
												SELECT DISTINCT IN_DATE, IN_PAY_NUM
												FROM 
													dbo.IncomeTable INNER JOIN
													dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
												WHERE ID_ID_DISTR = BD_ID_DISTR 
													AND ID_ID_PERIOD = BL_ID_PERIOD
													AND IN_ID_CLIENT = BL_ID_CLIENT
											) AS o_O
										ORDER BY IN_DATE DESC, IN_PAY_NUM FOR XML PATH('')
									)
								)
						, 1, 1, '')), '') AS IN_DATE,
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM dbo.IncomeIXView WITH(NOEXPAND)
					/*
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
					*/
				WHERE ID_ID_DISTR = BD_ID_DISTR 
					AND ID_ID_PERIOD = BL_ID_PERIOD
					AND IN_ID_CLIENT = BL_ID_CLIENT
			), 0) AS BD_PAYED_PRICE,
			(
				SELECT TOP 1 COUR_NAME
				FROM 
					dbo.TOTable INNER JOIN
					dbo.CourierTable ON TO_ID_COUR = COUR_ID
				WHERE TO_ID_CLIENT = CL_ID
				ORDER BY TO_MAIN DESC
			) AS COUR_NAME
		FROM 
			dbo.BillIXView WITH(NOEXPAND) INNER JOIN
			/*
			dbo.BillDistrTable INNER JOIN
			*/
			dbo.DistrView a ON a.DIS_ID = BD_ID_DISTR INNER JOIN
			/*
			dbo.BillTable ON BL_ID = BD_ID_BILL INNER JOIN
			*/
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
			dbo.CLientTable ON BL_ID_CLIENT = CL_ID 
		WHERE  
			(DOC_PSEDO = 'ACT') AND
			DD_PRINT = 1 AND			
			PR_DATE <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @periodid) AND
			NOT EXISTS
			(
				SELECT *
				FROM dbo.ActIXView WITH(NOEXPAND)
					/*
					dbo.ActTable INNER JOIN
					dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
					*/
				WHERE AD_ID_DISTR = BD_ID_DISTR
					AND BL_ID_PERIOD = AD_ID_PERIOD
					AND BL_ID_CLIENT = ACT_ID_CLIENT
			) AND
			-- неоплаченная сумма счета
			BD_TOTAL_PRICE = 
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM dbo.IncomeIXView WITH(NOEXPAND)
					/*
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
					*/
				WHERE ID_ID_DISTR = BD_ID_DISTR 
					AND ID_ID_PERIOD = BL_ID_PERIOD
					AND IN_ID_CLIENT = BL_ID_CLIENT
			), 0)
		ORDER BY COUR_NAME, CL_PSEDO, SYS_ORDER, PR_DATE DESC
		

END


