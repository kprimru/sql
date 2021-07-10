USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[REPORT_INCOME_SELECT]
	@indate SMALLDATETIME,
	@orgid SMALLINT = 1,
	@courlist VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cour TABLE (CR_ID SMALLINT)

	IF @courlist IS NULL
		INSERT INTO @cour
			SELECT COUR_ID
			FROM dbo.CourierTable
	ELSE
		INSERT INTO @cour
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@courlist, ',')

	SELECT
			CL_ID, CL_PSEDO, CL_FULL_NAME,
			SYS_ORDER, DIS_ID, DIS_STR, IN_PRICE,
			COUR_NAME, LAST_MONTH,
			(
				SELECT
					ISNULL((
						SELECT SUM(ID_PRICE) 
						FROM
							dbo.IncomeDistrTable INNER JOIN
							dbo.IncomeTable ON IN_ID = ID_ID_INCOME INNER JOIN
							dbo.PeriodTable ON PR_ID = ID_ID_PERIOD
						WHERE ID_ID_DISTR = DIS_ID
							AND IN_ID_ORG = @orgid
							AND IN_ID_CLIENT = CL_ID
							AND PR_DATE > ISNULL(LAST_MONTH, DATEADD(DAY, -1, PR_DATE))
					), 0) -
					ISNULL((
								SELECT TOP 1 BD_TOTAL_PRICE
								FROM
									dbo.BillDistrTable INNER JOIN
									dbo.BillTable ON BL_ID = BD_ID_BILL INNER JOIN
									dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
								WHERE BD_ID_DISTR = DIS_ID
									AND PR_DATE > ISNULL(LAST_MONTH, DATEADD(DAY, -1, PR_DATE))
									AND BL_ID_CLIENT = CL_ID
								ORDER BY PR_DATE
							), 0)
			) AS DIS_REST
	FROM
		(
			SELECT
				CL_ID, CL_PSEDO, CL_FULL_NAME, SYS_ORDER, DIS_ID, DIS_STR, SUM(ID_PRICE) AS IN_PRICE,
				(
					SELECT TOP 1 PR_DATE
					FROM
						dbo.PeriodTable
					WHERE
						(
							SELECT BD_TOTAL_PRICE -
								ISNULL(
									(
										SELECT SUM(ID_PRICE)
										FROM
											dbo.IncomeDistrTable INNER JOIN
											dbo.IncomeTable ON ID_ID_INCOME = IN_ID
										WHERE IN_ID_CLIENT = BL_ID_CLIENT
											AND ID_ID_DISTR = BD_ID_DISTR
											AND ID_ID_PERIOD = BL_ID_PERIOD
									)
									, 0)
							FROM
								dbo.BillDistrTable INNER JOIN
								dbo.BillTable ON BD_ID_BILL = BL_ID
							WHERE BD_ID_DISTR = DIS_ID
								AND BL_ID_CLIENT = CL_ID
								AND BL_ID_PERIOD = PR_ID
						) = 0
					ORDER BY PR_DATE DESC
				) AS LAST_MONTH,
				(
					SELECT TOP 1 COUR_ID
					FROM
						dbo.TOTable LEFT OUTER JOIN
						dbo.CourierTable ON COUR_ID = TO_ID_COUR
					WHERE CL_ID = TO_ID_CLIENT AND TO_ID_COUR IS NOT NULL
					ORDER BY TO_MAIN DESC
				) AS COUR_ID
			FROM
				dbo.ClientTable INNER JOIN
				dbo.IncomeTable ON IN_ID_CLIENT = CL_ID INNER JOIN
				dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID INNER JOIN
				dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
			WHERE IN_DATE = @indate AND IN_ID_ORG = @orgid
			GROUP BY CL_PSEDO, CL_FULL_NAME, DIS_STR, CL_ID, DIS_ID, SYS_ORDER
		) AS a INNER JOIN
		dbo.CourierTable b ON a.COUR_ID = b.COUR_ID INNER JOIN
		@cour ON CR_ID = a.COUR_ID
	ORDER BY COUR_NAME, CL_PSEDO, SYS_ORDER
END
GO
GRANT EXECUTE ON [dbo].[REPORT_INCOME_SELECT] TO rl_report_income_r;
GO