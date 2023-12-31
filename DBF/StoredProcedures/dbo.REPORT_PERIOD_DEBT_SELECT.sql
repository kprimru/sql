USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_PERIOD_DEBT_SELECT]
	@PR_ID	SMALLINT,
	@CUR	BIT
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

		SELECT ORG_PSEDO, CL_ID, CL_PSEDO, DIS_STR, BD_TOTAL_PRICE, IN_SUM, BD_TOTAL_PRICE - IN_SUM AS DEBT, PR_DATE
		FROM
			(
				SELECT
					CL_ID, CL_PSEDO, DIS_STR, SYS_ORDER, BD_TOTAL_PRICE,
					-- ����� ������ �� ���� ������
					ISNULL((
						SELECT SUM(ID_PRICE)
						FROM
							dbo.IncomeTable
							INNER JOIN dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME
						WHERE IN_ID_CLIENT = CL_ID AND ID_ID_DISTR = DIS_ID AND ID_ID_PERIOD = BL_ID_PERIOD
					), 0) AS IN_SUM, ORG_PSEDO, PR_DATE
				FROM
					dbo.BillTable
					INNER JOIN dbo.BillDistrTable ON BL_ID = BD_ID_BILL
					INNER JOIN dbo.ClientDistrTable ON CD_ID_CLIENT = BL_ID_CLIENT AND CD_ID_DISTR = BD_ID_DISTR
					INNER JOIN dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
					INNER JOIN dbo.ClientTable ON CL_ID = BL_ID_CLIENT
					INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR
					INNER JOIN dbo.OrganizationTable ON CL_ID_ORG = ORG_ID
					INNER JOIN dbo.PeriodTable ON BL_ID_PERIOD = PR_ID
				WHERE DSS_REPORT = 1 AND (PR_ID = @PR_ID AND @CUR = 1 OR PR_ID = dbo.PERIOD_PREV(@PR_ID))
			) AS o_O
		WHERE BD_TOTAL_PRICE <> IN_SUM
		ORDER BY CL_PSEDO, SYS_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_PERIOD_DEBT_SELECT] TO rl_report_debt;
GO
