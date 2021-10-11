USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[BILL_DETAIL_SELECT]
	@billid INT,
	@soid SMALLINT
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
				BD_ID, DIS_ID, DIS_STR, TX_NAME, TX_PERCENT, BD_PRICE,
				BD_TAX_PRICE, BD_TOTAL_PRICE,
				(
					ISNULL(
						(
							SELECT SUM(ID_PRICE)
							FROM
								dbo.IncomeTable INNER JOIN
								dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
							WHERE IN_ID_CLIENT = BL_ID_CLIENT
								AND ID_ID_PERIOD = PR_ID
								AND ID_ID_DISTR = DIS_ID
						)
					, 0)
				) AS BD_PAY,
				(
					BD_TOTAL_PRICE -
					ISNULL(
						(
							SELECT SUM(ID_PRICE)
							FROM
								dbo.IncomeTable INNER JOIN
								dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
							WHERE IN_ID_CLIENT = BL_ID_CLIENT
								AND ID_ID_PERIOD = PR_ID
								AND ID_ID_DISTR = DIS_ID
						)
					, 0)
				) AS BD_UNPAY, BD_DATE
		FROM
			dbo.BillDistrView
		WHERE BL_ID = @billid AND SO_ID = @soid
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
GRANT EXECUTE ON [dbo].[BILL_DETAIL_SELECT] TO rl_bill_r;
GO
