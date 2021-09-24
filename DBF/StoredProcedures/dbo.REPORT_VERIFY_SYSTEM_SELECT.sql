USE [DBF]
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

ALTER PROCEDURE [dbo].[REPORT_VERIFY_SYSTEM_SELECT]
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@clientid INT
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

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		CREATE TABLE #master
			(
				SYS_SHORT_NAME VARCHAR(20),
				SYS_ORDER INT,
				DIS_NUM INT,
				DIS_COMP_NUM TINYINT,
				DIS_ID INT,
				SL_REST MONEY
			)

		INSERT INTO #master(SYS_SHORT_NAME, SYS_ORDER, DIS_NUM, DIS_COMP_NUM, DIS_ID, SL_REST)
			SELECT
				DISTINCT SYS_SHORT_NAME, SYS_ORDER, DIS_NUM, DIS_COMP_NUM, DIS_ID,
				(
					SELECT TOP 1 SL_REST
					FROM dbo.SaldoView b
					WHERE a.SL_ID_DISTR = b.SL_ID_DISTR
						AND b.SL_ID_CLIENT = @clientid
						AND SL_DATE < @begindate
					ORDER BY SL_DATE DESC, SL_ID DESC
				)
			FROM
				dbo.SaldoView a INNER JOIN
				dbo.DistrView WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR
			WHERE SL_ID_CLIENT = @clientid

		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		CREATE TABLE #detail
			(
				SL_DATE SMALLDATETIME,
				DIS_ID INT,
				DIS_STR VARCHAR(50),
				ID_PRICE MONEY NULL,
				AD_TOTAL_PRICE MONEY NULL,
				SL_REST MONEY,
				PR_DATE SMALLDATETIME
			)
		INSERT INTO #detail
				(
					SL_DATE, DIS_ID, DIS_STR, ID_PRICE, AD_TOTAL_PRICE, SL_REST, PR_DATE
				)
			SELECT
				SL_DATE, d.DIS_ID, DIS_STR, a.ID_PRICE, NULL, a.SL_REST, PR_DATE
			FROM
				dbo.SaldoView a INNER JOIN
				dbo.DistrView d WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR INNER JOIN
				#master c ON d.DIS_ID = c.DIS_ID LEFT OUTER JOIN
				dbo.IncomeDistrTable b ON b.ID_ID = a.ID_ID LEFT OUTER JOIN
				dbo.PeriodTable ON ID_ID_PERIOD = PR_ID
			WHERE SL_ID_CLIENT = @clientid
				AND SL_DATE BETWEEN @begindate AND @enddate
				AND a.ID_PRICE IS NOT NULL

			UNION

			SELECT
				SL_DATE, d.DIS_ID, DIS_STR, NULL, a.AD_TOTAL_PRICE, a.SL_REST, PR_DATE
			FROM
				dbo.SaldoView a INNER JOIN
				dbo.DistrView d WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR INNER JOIN
				#master c ON d.DIS_ID = c.DIS_ID LEFT OUTER JOIN
				dbo.ActDistrTable b ON a.AD_ID = b.AD_ID LEFT OUTER JOIN
				dbo.PeriodTable ON AD_ID_PERIOD = PR_ID
			WHERE SL_ID_CLIENT = @clientid
				AND SL_DATE BETWEEN @begindate AND @enddate
				AND a.AD_TOTAL_PRICE IS NOT NULL

			UNION

			SELECT
				SL_DATE, d.DIS_ID, DIS_STR, NULL, a.CSD_TOTAL_PRICE, a.SL_REST, PR_DATE
			FROM
				dbo.SaldoView a INNER JOIN
				dbo.DistrView d WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR INNER JOIN
				#master c ON d.DIS_ID = c.DIS_ID LEFT OUTER JOIN
				dbo.ConsignmentDetailTable b ON a.CSD_ID = b.CSD_ID LEFT OUTER JOIN
				dbo.PeriodTable ON CSD_ID_PERIOD = PR_ID
			WHERE SL_ID_CLIENT = @clientid
				AND SL_DATE BETWEEN @begindate AND @enddate
				AND a.CSD_TOTAL_PRICE IS NOT NULL
			ORDER BY DIS_STR, a.SL_DATE

		SELECT * FROM #master ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM
		SELECT * FROM #detail ORDER BY DIS_ID, SL_DATE

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master
		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_VERIFY_SYSTEM_SELECT] TO rl_report_verify_r;
GO
