USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REPORT_SALDO_1C]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REPORT_SALDO_1C]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[REPORT_SALDO_1C]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	INT
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

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act

		IF OBJECT_ID('tempdb..#income') IS NOT NULL
			DROP TABLE #income

		IF OBJECT_ID('tempdb..#rest') IS NOT NULL
			DROP TABLE #rest

		CREATE TABLE #act
			(
				CL_ID	INT,
				SYS_ID	INT,
				ACT_SUM	MONEY
			)

		CREATE TABLE #income
			(
				CL_ID	INT,
				SYS_ID	INT,
				IN_SUM	MONEY
			)

		CREATE TABLE #rest
			(
				CL_ID	INT,
				SYS_ID	INT,
				REST	MONEY,
				DATE	SMALLDATETIME
			)

		DECLARE @SQL	NVARCHAR(MAX)
	/*
		INSERT INTO #act(CL_ID, SYS_ID, ACT_SUM)
			SELECT
				CL_ID, SYS_ID, SUM(AD_PRICE)
			FROM 
				dbo.ClientTable
				INNER JOIN dbo.ActTable ON ACT_ID_CLIENT = CL_ID
				INNER JOIN dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
				INNER JOIN dbo.DistrView a ON DIS_ID = AD_ID_DISTR 
			WHERE ACT_DATE BETWEEN @begin AND @end
				AND (ACT_ID_ORG = @org OR @org IS NULL)
			GROUP BY CL_ID, SYS_ID

			UNION ALL

			SELECT
				CL_ID, SYS_ID, SUM(CSD_PRICE)
			FROM 
				dbo.ClientTable
				INNER JOIN dbo.ConsignmentTable ON CSG_ID_CLIENT = CL_ID
				INNER JOIN dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID
				INNER JOIN dbo.DistrView a ON DIS_ID = CSD_ID_DISTR
			WHERE CSG_DATE BETWEEN @begin AND @end
				AND (CSG_ID_ORG = @org OR @org IS NULL)
			GROUP BY CL_ID, SYS_ID

		INSERT INTO #income(CL_ID, SYS_ID, IN_SUM)
			SELECT
				CL_ID, SYS_ID, SUM(ID_PRICE)
			FROM
				dbo.IncomeTable INNER JOIN
				dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
				dbo.DistrView ON DIS_ID = ID_ID_DISTR INNER JOIN
				dbo.ClientTable ON CL_ID = IN_ID_CLIENT
			WHERE IN_DATE BETWEEN @BEGIN AND @END
				AND IN_ID_ORG = @org
			GROUP BY CL_ID, SYS_ID
	*/
		INSERT INTO #rest(CL_ID, SYS_ID, REST, DATE)
			SELECT
				SL_ID_CLIENT, SYS_ID, SL_REST, SL_DATE
			FROM
				(
					SELECT SL_ID_CLIENT, SYS_ID, SUM(SL_REST) AS SL_REST, MAX(SL_DATE) AS SL_DATE
					FROM
						(
							SELECT
								SYS_ID, SL_ID_CLIENT, SL_ID_DISTR,
								--SL_REST,
								SL_REST - ROUND((TX_PERCENT * SL_REST / (100 + TX_PERCENT)), 2) AS SL_REST,
								SL_DATE
							FROM
								(
									SELECT
										SL_ID_CLIENT, SL_ID_DISTR,
										(
											SELECT TOP 1 SL_REST
											FROM dbo.SaldoView b
											WHERE a.SL_ID_CLIENT = b.SL_ID_CLIENT
												AND a.SL_ID_DISTR = b.SL_ID_DISTR
												AND SL_DATE <= @END
											ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
										) AS SL_REST,
										(
											SELECT TOP 1 SL_DATE
											FROM dbo.SaldoView b
											WHERE a.SL_ID_CLIENT = b.SL_ID_CLIENT
												AND a.SL_ID_DISTR = b.SL_ID_DISTR
												AND SL_DATE <= @END
											ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
										) AS SL_DATE
									FROM
										(
											SELECT DISTINCT CL_ID AS SL_ID_CLIENT, DIS_ID AS SL_ID_DISTR
											FROM
												dbo.ClientTable
												INNER JOIN dbo.ClientDistrView ON CD_ID_CLIENT = CL_ID
											WHERE DSS_REPORT = 1 AND CL_ID_ORG = @ORG AND DIS_ACTIVE = 1

											UNION

											SELECT DISTINCT SL_ID_CLIENT, SL_ID_DISTR
											FROM
												dbo.SaldoTable
												LEFT OUTER JOIN dbo.IncomeDistrTable ON SL_ID_IN_DIS = ID_ID
												LEFT OUTER JOIN dbo.IncomeTable ON ID_ID_INCOME = IN_ID
												LEFT OUTER JOIN dbo.ActDistrTable ON SL_ID_ACT_DIS = AD_ID
												LEFT OUTER JOIN dbo.ActTable ON AD_ID_ACT = ACT_ID
												LEFT OUTER JOIN dbo.ConsignmentDetailTable ON SL_ID_CONSIG_DIS = CSD_ID
												LEFT OUTER JOIN dbo.ConsignmentTable ON CSD_ID_CONS = CSG_ID
											WHERE /*SL_DATE >= '20090101'
												AND*/	(
														IN_ID_ORG = @ORG AND SL_ID_IN_DIS IS NOT NULL
														OR
														ACT_ID_ORG = @ORG AND SL_ID_ACT_DIS IS NOT NULL
														OR
														CSG_ID_ORG = @ORG AND SL_ID_CONSIG_DIS IS NOT NULL
													)
												AND NOT EXISTS
													(
														SELECT *
														FROM
															dbo.ClientTable
															INNER JOIN dbo.ClientDistrView ON CD_ID_CLIENT = CL_ID
														WHERE DSS_REPORT = 1 AND CL_ID_ORG = @ORG AND DIS_ACTIVE = 1
															AND  CL_ID = SL_ID_CLIENT AND DIS_ID= SL_ID_DISTR
													)
										) AS a
								) AS c
								INNER JOIN dbo.DistrView d WITH(NOEXPAND) ON c.SL_ID_DISTR = d.DIS_ID
								INNER JOIN dbo.SaleObjectTable ON SYS_ID_SO = SO_ID
								INNER JOIN dbo.TaxTable ON TX_ID = SO_ID_TAX
						) AS e
					GROUP BY SL_ID_CLIENT, SYS_ID
				) AS o_O

		SELECT a.CL_ID, CL_PSEDO, CL_INN, a.SYS_ID, SYS_SHORT_NAME, SYS_1C_CODE, SYS_ORDER, /*IN_SUM, ACT_SUM, */REST, DATE
		FROM
			(
				/*SELECT DISTINCT CL_ID, SYS_ID
				FROM #act

				UNION

				SELECT DISTINCT CL_ID, SYS_ID
				FROM #income

				UNION
				*/
				SELECT DISTINCT CL_ID, SYS_ID
				FROM #rest
			) AS a
			INNER JOIN dbo.ClientTable b ON a.CL_ID = b.CL_ID
			INNER JOIN dbo.SystemTable c ON c.SYS_ID = a.SYS_ID
			--LEFT OUTER JOIN #income d ON d.CL_ID = a.CL_ID AND d.SYS_ID = a.SYS_ID
			--LEFT OUTER JOIN #act e ON e.CL_ID = a.CL_ID AND e.SYS_ID = a.SYS_ID
			LEFT OUTER JOIN #rest f ON f.CL_ID = a.CL_ID AND f.SYS_ID = a.SYS_ID
		ORDER BY SYS_ORDER, CL_PSEDO

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act

		IF OBJECT_ID('tempdb..#income') IS NOT NULL
			DROP TABLE #income

		IF OBJECT_ID('tempdb..#rest') IS NOT NULL
			DROP TABLE #rest

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_SALDO_1C] TO rl_report_act_r;
GO
