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
ALTER PROCEDURE [dbo].[REPORT_ACT_OUT]
	@periodid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @periodid

		SELECT
				CL_ID, CL_PSEDO, CL_FULL_NAME
				PR_ID, PR_DATE, a.DIS_ID, DIS_STR, BD_TOTAL_PRICE,
				ISNULL((
					SELECT SUM(ID_PRICE)
					FROM
						dbo.IncomeTable INNER JOIN
						dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
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
				dbo.BillDistrTable INNER JOIN
				dbo.DistrView a WITH(NOEXPAND) ON a.DIS_ID = BD_ID_DISTR INNER JOIN
				dbo.BillTable ON BL_ID = BD_ID_BILL INNER JOIN
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
					FROM
						dbo.ActTable INNER JOIN
						dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
					WHERE AD_ID_DISTR = BD_ID_DISTR
						AND BL_ID_PERIOD = AD_ID_PERIOD
						AND BL_ID_CLIENT = ACT_ID_CLIENT
				) AND
				-- неоплаченная сумма счета
				/*
				EXISTS
					(
						SELECT *
						FROM dbo.SaldoLastView z
						WHERE z.CL_ID = c.CL_ID
							AND SL_REST >= 0
					) AND
					*/
				BD_TOTAL_PRICE >
				ISNULL((
					SELECT SUM(ID_PRICE)
					FROM
						dbo.IncomeTable INNER JOIN
						dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
					WHERE ID_ID_DISTR = BD_ID_DISTR
						AND ID_ID_PERIOD = BL_ID_PERIOD
						AND IN_ID_CLIENT = BL_ID_CLIENT
				), 0)
			ORDER BY COUR_NAME, CL_PSEDO, SYS_ORDER, PR_DATE DESC

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_ACT_OUT] TO rl_report_act_r;
GO