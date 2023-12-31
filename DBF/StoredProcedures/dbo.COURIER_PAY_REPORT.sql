USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[COURIER_PAY_REPORT]
	@PERIOD SMALLINT,
	@COUR_LIST VARCHAR(MAX) = NULL
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PERIOD

		DECLARE @COUR TABLE (CR_ID SMALLINT)

		IF @COUR_LIST IS NULL
			INSERT INTO @COUR
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO @COUR
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@COUR_LIST, ',')

		SELECT
			CL_ID, COUR_NAME, CL_PSEDO, COP_ID, COP_NAME, PAY_MONTH, COP_DAY, COP_MONTH,
			DATENAME(MONTH, PAY_MONTH) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, PAY_MONTH)) AS PAY_MONTH_STR,
			CASE DATEPART(MONTH, DATEADD(MONTH, COP_MONTH, PAY_MONTH))
				WHEN 2 THEN
					CASE COP_DAY
						WHEN 30 THEN DATEADD(DAY, -1, DATEADD(MONTH, COP_MONTH + 1, PAY_MONTH))
						ELSE DATEADD(DAY, DATEPART(DAY, COP_DAY) - 1, DATEADD(MONTH, COP_MONTH, PAY_MONTH))
					END
				ELSE DATEADD(DAY, DATEPART(DAY, COP_DAY) - 1, DATEADD(MONTH, COP_MONTH, PAY_MONTH))
			END AS MAX_DATE,
			(
				SELECT MAX(IN_DATE)
				FROM
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
					dbo.DistrFinancingTable ON DF_ID_DISTR = ID_ID_DISTR INNER JOIN
					dbo.BillRestView t ON BL_ID_CLIENT = IN_ID_CLIENT
								AND ID_ID_DISTR = BD_ID_DISTR
								AND ID_ID_PERIOD = BL_ID_PERIOD
				WHERE ID_ID_PERIOD = (SELECT PR_ID FROM dbo.PeriodTable WHERE PR_DATE = PAY_MONTH)
					AND IN_ID_CLIENT = CL_ID AND DF_ID_PAY = COP_ID AND BD_REST = 0
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.BillRestView q
							WHERE t.BL_ID_CLIENT = q.BL_ID_CLIENT
								AND t.BL_ID_PERIOD = q.BL_ID_PERIOD
								AND BD_REST <> 0
						)
			) AS PAY_DATE,
			(
				SELECT COUNT(*)
				FROM
					dbo.BillRestView INNER JOIN
					dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
				WHERE BL_ID_CLIENT = CL_ID
					AND BL_ID_PERIOD = (SELECT PR_ID FROM dbo.PeriodTable WHERE PR_DATE = PAY_MONTH)
					AND BD_REST = 0
			) AS PAY_DISTR_COUNT,
			(
				SELECT COUNT(*)
				FROM
					dbo.BillRestView INNER JOIN
					dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
				WHERE BL_ID_CLIENT = CL_ID
					AND BL_ID_PERIOD = (SELECT PR_ID FROM dbo.PeriodTable WHERE PR_DATE = PAY_MONTH)
					AND BD_REST <> 0
			) AS UNPAY_DISTR_COUNT,
			REVERSE(STUFF(REVERSE((
				SELECT DIS_STR + ' (' + CONVERT(VARCHAR(20), BD_REST) + ')' + CHAR(10)
				FROM
					dbo.BillRestView INNER JOIN
					dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
				WHERE BL_ID_CLIENT = CL_ID
					AND BL_ID_PERIOD = (SELECT PR_ID FROM dbo.PeriodTable WHERE PR_DATE = PAY_MONTH)
					AND BD_REST <> 0
				ORDER BY SYS_ORDER FOR XML PATH('')
			)), 1, 1, '')) AS UNPAY_DISTR
		FROM
			(
				SELECT
					CL_ID, COUR_NAME, CL_PSEDO, COP_ID, COP_NAME, COP_DAY, COP_MONTH,
					(
						SELECT PR_DATE
						FROM dbo.PeriodTable
						WHERE PR_DATE = DATEADD(MONTH, -COP_MONTH, @PR_DATE)
					) AS PAY_MONTH
				FROM
					(
						SELECT DISTINCT
							CL_ID, COUR_NAME, CL_PSEDO, COP_NAME, COP_ID, COP_MONTH, COP_DAY
						FROM
							dbo.ClientCourView INNER JOIN
							@COUR ON CR_ID = COUR_ID INNER JOIN
							dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
							dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON CD_ID_DISTR = DIS_ID INNER JOIN
							dbo.DistrFinancingTable ON DF_ID_DISTR = CD_ID_DISTR LEFT OUTER JOIN
							dbo.ContractPayTable ON DF_ID_PAY = COP_ID
						WHERE SYS_ID_SO = 1 AND DSS_REPORT = 1
					) AS o_O
			) AS ooo
		ORDER BY COUR_NAME, CL_PSEDO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[COURIER_PAY_REPORT] TO rl_courier_pay;
GO
