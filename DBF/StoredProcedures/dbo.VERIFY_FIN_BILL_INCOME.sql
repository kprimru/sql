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

ALTER PROCEDURE [dbo].[VERIFY_FIN_BILL_INCOME]
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

		SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE, ID_PRICE, BD_TOTAL_PRICE
		FROM
			(
				SELECT
					BL_ID_CLIENT,
					BL_ID_PERIOD,
					BD_ID_DISTR,
					BD_TOTAL_PRICE, ID_PRICE
				FROM

					(
						SELECT
							BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, BD_TOTAL_PRICE
						FROM
							dbo.BillTable a INNER JOIN
							dbo.BillDistrTable b ON BL_ID=BD_ID_BILL
					)
					AS Bills
					INNER JOIN
					(
						SELECT
							IN_ID_CLIENT, ID_ID_PERIOD, ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE
						FROM
							dbo.IncomeTable a INNER JOIN
							dbo.IncomeDistrTable b ON IN_ID=ID_ID_INCOME
						GROUP BY IN_ID_CLIENT, ID_ID_PERIOD, ID_ID_DISTR
					)
					AS Incomes
					ON Incomes.IN_ID_CLIENT=Bills.BL_ID_CLIENT AND Incomes.ID_ID_PERIOD=Bills.BL_ID_PERIOD
						AND Bills.BD_ID_DISTR=Incomes.ID_ID_DISTR
				WHERE BD_TOTAL_PRICE < ID_PRICE
			) AS o_O INNER JOIN
			dbo.ClientTable ON BL_ID_CLIENT = CL_ID INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR INNER JOIN
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
		ORDER BY CL_PSEDO, DIS_STR, PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[VERIFY_FIN_BILL_INCOME] TO rl_audit_fin;
GO