USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			
���� ��������:  	
��������:		
*/
CREATE PROCEDURE [dbo].[REPORT_ACT_OUT_NEW]
	@periodid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @periodid

	SELECT 
			CL_ID, CL_PSEDO, CL_FULL_NAME
			PR_ID, PR_DATE, a.DIS_ID, DIS_STR, BD_TOTAL_PRICE, 
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM dbo.IncomeIXView WITH(NOEXPAND)
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
			) AS COUR_NAME
		FROM 
			dbo.BillIXView WITH(NOEXPAND) INNER JOIN
			dbo.DistrView a ON a.DIS_ID = BD_ID_DISTR INNER JOIN
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
			dbo.CLientTable c ON BL_ID_CLIENT = CL_ID INNER JOIN
			dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID AND a.DIS_ID = CD_ID_DISTR INNER JOIN
			dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
		WHERE  
			(DOC_PSEDO = 'ACT') AND
			DD_PRINT = 1 AND
			DSS_REPORT = 1 AND
			PR_DATE <= @PR_DATE AND
			NOT EXISTS
			(
				SELECT *
				FROM dbo.ActIXView WITH(NOEXPAND)
				WHERE AD_ID_DISTR = BD_ID_DISTR
					AND BL_ID_PERIOD = AD_ID_PERIOD
					AND BL_ID_CLIENT = ACT_ID_CLIENT
			) AND
			-- ������������ ����� �����
			EXISTS
				(
					SELECT *
					FROM dbo.SaldoLastView z
					WHERE z.CL_ID = c.CL_ID
						AND SL_REST >= 0
				) AND
			BD_TOTAL_PRICE > 
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