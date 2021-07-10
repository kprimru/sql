USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BILL_REST_GET]
	@clientid INT,
	@periodid SMALLINT
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

		SELECT
			BD_ID, DIS_ID, DIS_STR, BD_TOTAL_PRICE,
				(
					SELECT SUM(ID_PRICE)
					FROM
						dbo.IncomeDistrTable INNER JOIN
						dbo.IncomeTable ON ID_ID_INCOME = IN_ID INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
						dbo.SaleObjectTable b ON SO_ID = SYS_ID_SO
					WHERE ID_ID_DISTR = DIS_ID
						AND ID_ID_PERIOD = PR_ID
						AND IN_ID_CLIENT = BL_ID_CLIENT
						AND b.SO_ID = a.SO_ID
				) AS BD_PAY,
			BD_TOTAL_PRICE -
				ISNULL((
					SELECT SUM(ID_PRICE)
					FROM
						dbo.IncomeDistrTable INNER JOIN
						dbo.IncomeTable ON ID_ID_INCOME = IN_ID INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
						dbo.SaleObjectTable b ON SO_ID = SYS_ID_SO
					WHERE ID_ID_DISTR = DIS_ID
						AND ID_ID_PERIOD = PR_ID
						AND IN_ID_CLIENT = BL_ID_CLIENT
						AND b.SO_ID = a.SO_ID
				), 0) AS BD_UNPAY
		FROM
			dbo.BillDistrView a
		WHERE PR_ID = @periodid AND BL_ID_CLIENT = @clientid
		ORDER BY DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BILL_REST_GET] TO rl_bill_r;
GO