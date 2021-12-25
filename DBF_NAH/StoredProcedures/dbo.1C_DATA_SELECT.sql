USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[1C_DATA_SELECT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	SMALLINT
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
				REST	MONEY
			)

		DECLARE @SQL	NVARCHAR(MAX)

		INSERT INTO #act(CL_ID, SYS_ID, ACT_SUM)
			SELECT
				CL_ID, SYS_ID, SUM(AD_PRICE)
			FROM 
				dbo.ClientTable
				INNER JOIN dbo.ActTable ON ACT_ID_CLIENT = CL_ID
				INNER JOIN dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
				INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR
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
				INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR
			WHERE CSG_DATE BETWEEN @begin AND @end
				AND (CSG_ID_ORG = @org OR @org IS NULL)
			GROUP BY CL_ID, SYS_ID

		INSERT INTO #income(CL_ID, SYS_ID, IN_SUM)
			SELECT
				CL_ID, SYS_ID, SUM(ID_PRICE)
			FROM
				dbo.IncomeTable INNER JOIN
				dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME INNER JOIN
				dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
				dbo.ClientTable ON CL_ID = IN_ID_CLIENT
			WHERE IN_DATE BETWEEN @BEGIN AND @END
				AND IN_ID_ORG = @org
			GROUP BY CL_ID, SYS_ID

		INSERT INTO #rest(CL_ID, SYS_ID, REST)
			SELECT
				SL_ID_CLIENT, SYS_ID, SL_REST
			FROM
				(
					SELECT SL_ID_CLIENT, SYS_ID, SUM(SL_REST) AS SL_REST
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
									ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
								) AS SL_REST
							FROM
								(
									SELECT DISTINCT SL_ID_CLIENT, SL_ID_DISTR
									FROM dbo.SaldoView
									WHERE SL_DATE BETWEEN @BEGIN AND @END
								) AS a
						) AS c
						INNER JOIN dbo.DistrView d WITH(NOEXPAND) ON c.SL_ID_DISTR = d.DIS_ID
					GROUP BY SL_ID_CLIENT, SYS_ID
				) AS e

		SELECT a.CL_ID, CL_PSEDO, CL_INN, a.SYS_ID, SYS_1C_CODE, SYS_ORDER, IN_SUM, ACT_SUM, REST
		FROM
			(
				SELECT DISTINCT CL_ID, SYS_ID
				FROM #act

				UNION

				SELECT DISTINCT CL_ID, SYS_ID
				FROM #income

				UNION

				SELECT DISTINCT CL_ID, SYS_ID
				FROM #rest
			) AS a
			INNER JOIN dbo.ClientTable b ON a.CL_ID = b.CL_ID
			INNER JOIN dbo.SystemTable c ON c.SYS_ID = a.SYS_ID
			LEFT OUTER JOIN #income d ON d.CL_ID = a.CL_ID AND d.SYS_ID = a.SYS_ID
			LEFT OUTER JOIN #act e ON e.CL_ID = a.CL_ID AND e.SYS_ID = a.SYS_ID
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
GRANT EXECUTE ON [dbo].[1C_DATA_SELECT] TO rl_report_act_r;
GO
