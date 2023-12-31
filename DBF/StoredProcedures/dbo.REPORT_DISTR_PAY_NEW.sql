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
ALTER PROCEDURE [dbo].[REPORT_DISTR_PAY_NEW]
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

		DECLARE @courier TABLE
			(
				COUR_ID SMALLINT
			)

		IF @cour IS NULL
			INSERT INTO @courier
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO @courier
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@cour, ',')

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @prid

		SELECT
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			DIS_STR, BD_TOTAL_PRICE, IN_PRICE, LAST_ACT, LAST_INCOME,
			CASE
				WHEN BD_TOTAL_PRICE = IN_PRICE THEN 1
				ELSE 0
			END AS RESULT,
			COUR_NAME
		FROM
			(
				SELECT
					CL_ID, CL_PSEDO, CL_FULL_NAME, DIS_STR, SYS_ORDER,
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
							SELECT MAX(Z.PR_DATE)
							FROM
								dbo.PeriodTable Z INNER JOIN
								dbo.ActIXView WITH(NOEXPAND) ON AD_ID_PERIOD = PR_ID
								/*
								dbo.ActDistrTable ON AD_ID_PERIOD = PR_ID INNER JOIN
								dbo.ActTable ON ACT_ID = AD_ID_ACT
								*/
							WHERE ACT_ID_CLIENT = CL_ID
								AND AD_ID_DISTR = DIS_ID
						) AS LAST_ACT,
						(
							SELECT MAX(Z.PR_DATE)
							FROM
								dbo.PeriodTable Z INNER JOIN
								dbo.BillIXView WITH(NOEXPAND) ON BL_ID_PERIOD = PR_ID
								/*
								dbo.BillTable ON BL_ID_PERIOD = PR_ID INNER JOIN
								dbo.BillDistrTable ON BD_ID_BILL = BL_ID
								*/
							WHERE BL_ID_CLIENT = CL_ID
								AND BD_ID_DISTR = DIS_ID
								AND BD_TOTAL_PRICE =
									(
										SELECT SUM(ID_PRICE)
										FROM dbo.IncomeIXView WITH(NOEXPAND)
											/*
											dbo.IncomeDistrTable INNER JOIN
											dbo.IncomeTable ON IN_ID = ID_ID_INCOME 
											*/
										WHERE ID_ID_DISTR = BD_ID_DISTR
											AND ID_ID_PERIOD = BL_ID_PERIOD
											AND IN_ID_CLIENT = BL_ID_CLIENT
									)
						) AS LAST_INCOME
					FROM
						dbo.ClientDistrTable INNER JOIN
						dbo.ClientTable ON CL_ID = CD_ID_CLIENT INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
						dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE LEFT OUTER JOIN
						dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID LEFT OUTER JOIN
						dbo.PeriodTable P ON PR_ID = DF_ID_PERIOD LEFT OUTER JOIN
						dbo.BillIXView WITH(NOEXPAND) ON BL_ID_CLIENT = CL_ID AND BL_ID_PERIOD = @prid AND BD_ID_DISTR = DIS_ID
						/*
						dbo.BillTable ON BL_ID_CLIENT = CL_ID AND BL_ID_PERIOD = @prid LEFT OUTER JOIN
						dbo.BillDistrTable ON BL_ID = BD_ID_BILL AND BD_ID_DISTR = DIS_ID
						*/
					WHERE DSS_REPORT = 1
						AND SYS_ID_SO = 1
						AND ISNULL(P.PR_DATE, @PR_DATE) <= @PR_DATE
			) AS a LEFT OUTER JOIN
			dbo.CourierTable b ON a.COUR_ID = b.COUR_ID INNER JOIN
			@courier c ON b.COUR_ID = c.COUR_ID
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, SYS_ORDER, DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
