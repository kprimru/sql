USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REPORT_DISTR_PAY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REPORT_DISTR_PAY]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[REPORT_DISTR_PAY]
	@prid SMALLINT,
	@date SMALLDATETIME,
	@cour VARCHAR(MAX)
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

		DECLARE @courier TABLE
			(
				COUR_ID SMALLINT PRIMARY KEY CLUSTERED
			)

		DECLARE @Distrs Table
		(
			DIS_ID			Int		NOT NULL,
			CL_ID			Int		NOT NULL,
			BD_TOTAL_PRICE	Money	NOT NULL
			PRIMARY KEY CLUSTERED(DIS_ID, CL_ID)
		);

		IF @cour IS NULL
			INSERT INTO @courier
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO @courier
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@cour, ',')

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @prid

		INSERT INTO @Distrs
		SELECT DIS_ID, CD_ID_CLIENT, BD_TOTAL_PRICE
		FROM dbo.DistrServiceStatusTable
		INNER JOIN dbo.ClientDistrTable ON DSS_ID = CD_ID_SERVICE
		INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR
		INNER JOIN dbo.BillIXView WITH(NOEXPAND) ON BL_ID_CLIENT = CD_ID_CLIENT AND BL_ID_PERIOD = @prid AND BD_ID_DISTR = DIS_ID
		LEFT OUTER JOIN dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID
		LEFT OUTER JOIN dbo.PeriodTable P ON PR_ID = DF_ID_PERIOD
		WHERE DSS_REPORT = 1
			AND SYS_ID_SO = 1
			AND ISNULL(P.PR_DATE, @PR_DATE) <= @PR_DATE

		SELECT
			a.CL_ID, CL_PSEDO, CL_FULL_NAME,
			DIS_STR, BD_TOTAL_PRICE, IN_PRICE, LAST_ACT, LAST_INCOME,
			CASE
				WHEN BD_TOTAL_PRICE = IN_PRICE THEN 1
				ELSE 0
			END AS RESULT,
			COUR_NAME
		FROM
			(
				SELECT
					CL_ID, DIS_ID,
					ISNULL(BD_TOTAL_PRICE, 0) AS BD_TOTAL_PRICE,
						ISNULL((
							SELECT SUM(ID_PRICE)
							FROM
								dbo.IncomeTable INNER JOIN
								dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME
							WHERE IN_ID_CLIENT = CL_ID
								AND ID_ID_DISTR = DIS_ID
								AND ID_ID_PERIOD = @prid
								AND IN_DATE <= @date
						), 0) AS IN_PRICE,
						(
							SELECT COUR_ID
							FROM
								dbo.CourierTable INNER JOIN
								dbo.TOTable ON TO_ID_COUR = COUR_ID INNER JOIN
								dbo.TODistrTable ON TD_ID_TO = TO_ID
							WHERE TD_ID_DISTR = DIS_ID
						) AS COUR_ID,
						(
							SELECT TOP (1) PR_DATE
							FROM dbo.ActIXView WITH(NOEXPAND)
							WHERE ACT_ID_CLIENT = CL_ID
								AND AD_ID_DISTR = DIS_ID
							ORDER BY PR_DATE DESC
						) AS LAST_ACT,
						(
							SELECT TOP (1) PR_DATE
							FROM dbo.BillIXView WITH(NOEXPAND)
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
							ORDER BY PR_DATE DESC
						) AS LAST_INCOME
					FROM @Distrs D
			) AS a
			INNER JOIN dbo.ClientTable CL ON CL.CL_ID = A.CL_ID
			INNER JOIN dbo.DistrView D WITH(NOEXPAND) ON D.DIS_ID = a.DIS_ID
			INNER JOIN dbo.CourierTable b ON a.COUR_ID = b.COUR_ID
			INNER JOIN @courier c ON b.COUR_ID = c.COUR_ID
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, SYS_ORDER, DIS_STR
		OPTION(RECOMPILE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_DISTR_PAY] TO rl_report_income_r;
GO
