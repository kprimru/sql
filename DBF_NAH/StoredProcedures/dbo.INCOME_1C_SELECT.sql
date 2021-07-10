USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[INCOME_1C_SELECT]
	@date	SMALLDATETIME,
	@org	INT,
	@calc	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CL_ID, CL_PSEDO, CL_INN,
		SYS_1C_CODE, SYS_SHORT_NAME AS DIS_STR,
		@date AS IN_PAY_DATE,
		dbo.IncomeSystemString(CL_ID, @date, SYS_ID) AS ID_MONTH,
		ID_PRICE, ID_NDS, ID_SUM, CONVERT(varchar(10),dbo.IncomeSystemPayString(CL_ID, SYS_ID, @date)) AS IN_PAY_NUM,
		ISNULL(ID_AVANS_NDS, 0) AS ID_AVANS_NDS
	FROM
		(
			SELECT
				CL_ID, CL_PSEDO, CL_INN, SYS_ID,
				SYS_SHORT_NAME, SYS_1C_CODE, SYS_ORDER,
				SUM(ID_SUM) AS ID_SUM, SUM(ID_PRICE) AS ID_PRICE, SUM(ID_NDS) AS ID_NDS,
				SUM(ID_AVANS_NDS) AS ID_AVANS_NDS
			FROM
				(
					SELECT
						CL_ID, CL_PSEDO, CL_INN, SYS_ID,
						SYS_SHORT_NAME,
						SYS_1C_CODE = CASE WHEN TX_PERCENT = 20 THEN SYS_1C_CODE2 ELSE SYS_1C_CODE END,
						SYS_ORDER,
						ID_PRICE AS ID_SUM,
						ID_PRICE - ROUND(ID_PRICE * TX_PERCENT / (100.0 + TX_PERCENT), 2) AS ID_PRICE,
						ROUND(ID_PRICE * TX_PERCENT / (100.0 + TX_PERCENT), 2) AS ID_NDS,
						ROUND(ID_AVANS * TX_PERCENT / (100.0 + TX_PERCENT), 2) AS ID_AVANS_NDS
					FROM
						dbo.IncomeTable
						INNER JOIN dbo.IncomeDistrTable o ON IN_ID = ID_ID_INCOME
						INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
						INNER JOIN dbo.ClientTable ON CL_ID = IN_ID_CLIENT
						INNER JOIN dbo.SaleObjectTable ON SYS_ID_SO = SO_ID
						INNER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
						OUTER APPLY
							(
								SELECT TOP 1 ID_PRICE - DELTA AS ID_AVANS
								FROM
									(
										SELECT
											ID_PRICE,
											CASE
												WHEN SL_REST >= 0 THEN 0
												WHEN ABS(SL_REST) > ID_PRICE THEN ID_PRICE
												ELSE ABS(SL_REST)
											END AS DELTA, SL_REST
										FROM
											(
												SELECT
													e.ID_PRICE, DELTA, SL_REST
												FROM
													dbo.IncomeTable
													INNER JOIN dbo.IncomeDistrTable c ON IN_ID = ID_ID_INCOME
													INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
													INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
													INNER JOIN dbo.TaxTable ON SO_ID_TAX = TX_ID
													INNER JOIN dbo.IncomeSaldoView e ON c.ID_ID = e.ID_ID
												WHERE c.ID_ID = o.ID_ID
													AND e.ID_PRICE > 0
											) AS o_O
										WHERE ABS(SL_REST) < ID_PRICE AND SL_REST > 0 OR SL_REST > 0
									) AS o_O
							) AS o_O
					WHERE
						IN_DATE = @date	 AND
						IN_ID_ORG = @org
						AND (@CALC IS NULL AND CL_ID_ORG_CALC IS NULL OR CL_ID_ORG_CALC = @CALC)
				) AS o_O
			GROUP BY CL_ID, CL_PSEDO, CL_INN, SYS_ID, SYS_SHORT_NAME, SYS_1C_CODE, SYS_ORDER
		) AS o_O
	ORDER BY CL_PSEDO, SYS_ORDER

	/*
	SELECT
		CL_ID, CL_PSEDO, CL_INN,
		SYS_1C_CODE, DIS_STR, @date AS IN_PAY_DATE,
		dbo.IncomeDistrString(CL_ID, @date, DIS_ID) AS ID_MONTH,
		ID_SUM, dbo.IncomePayString(CL_ID, DIS_ID, @date) AS IN_PAY_NUM
	FROM
		(
			SELECT
				CL_ID, CL_PSEDO, CL_INN, 
				DIS_ID, DIS_STR, SYS_1C_CODE, SYS_ORDER, SUM(ID_PRICE) AS ID_SUM
			FROM
				dbo.IncomeTable INNER JOIN
				dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
				dbo.DistrView ON DIS_ID = ID_ID_DISTR INNER JOIN
				dbo.ClientTable ON CL_ID = IN_ID_CLIENT
			WHERE
				IN_DATE = @date	 AND
				IN_ID_ORG = @org
			GROUP BY CL_ID, CL_PSEDO, CL_INN, 
				DIS_ID, DIS_STR, SYS_1C_CODE, SYS_ORDER
		) AS o_O
	ORDER BY CL_PSEDO, SYS_ORDER
	*/
END
GO
GRANT EXECUTE ON [dbo].[INCOME_1C_SELECT] TO rl_report_act_r;
GO