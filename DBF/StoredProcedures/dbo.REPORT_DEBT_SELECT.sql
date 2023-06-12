USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REPORT_DEBT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REPORT_DEBT_SELECT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[REPORT_DEBT_SELECT]
	@date SMALLDATETIME
WITH RECOMPILE
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

		--DECLARE @gavno TABLE (SL_ID_CLIENT INT, SL_ID_DISTR INT, SL_ID BIGINT)
		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		--сформировать последнее сальдо по всем за эту дату?
		CREATE TABLE #temp
			(
				SL_ID_CLIENT INT,
				SL_ID_DISTR INT,
				SL_DATE SMALLDATETIME,
				SL_REST MONEY
			)

		CREATE TABLE #distr
			(
				SL_ID_DISTR		INT,
				SL_ID_CLIENT	INT,
				SL_ID			BIGINT
			)

		INSERT INTO #distr(SL_ID_CLIENT, SL_ID_DISTR, SL_ID)
			SELECT
				SL_ID_CLIENT, SL_ID_DISTR,
				(
					SELECT TOP 1 SL_ID
					FROM dbo.SaldoTable b
					WHERE a.SL_ID_CLIENT = b.SL_ID_CLIENT
						AND a.SL_ID_DISTR = b.SL_ID_DISTR
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				) AS SL_ID
			FROM
				(
					SELECT DISTINCT SL_ID_CLIENT, SL_ID_DISTR
					FROM dbo.SaldoTable
				) AS a

		/*
		INSERT INTO @gavno
			SELECT
				DISTINCT SL_ID_CLIENT, SL_ID_DISTR,
				(
					SELECT TOP 1 SL_ID
					FROM dbo.SaldoTable b
					WHERE a.SL_ID_CLIENT = b.SL_ID_CLIENT
						AND a.SL_ID_DISTR = b.SL_ID_DISTR
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				) AS SL_ID
			FROM dbo.SaldoTable a
			WHERE SL_DATE <= @date
		*/

		INSERT INTO #temp
			SELECT
				a.SL_ID_CLIENT, b.SL_ID_DISTR, SL_DATE, SL_REST
			FROM
				#distr a INNER JOIN
				dbo.SaldoTable b ON a.SL_ID = b.SL_ID


		SELECT
			CL_ID, DIS_ID, CL_PSEDO, DIS_STR, SYS_ORDER, SN_ID, SN_NAME,
			SL_REST, SL_DATE AS SAL_DATE,
			(
				SELECT TOP 1 COUR_NAME
				FROM
					dbo.TOTable INNER JOIN
					dbo.CourierTable ON TO_ID_COUR = COUR_ID
				WHERE TO_ID_CLIENT = CL_ID
				ORDER BY TO_MAIN DESC
			) AS COUR_NAME
		FROM 
			#temp INNER JOIN
			dbo.ClientTable ON SL_ID_CLIENT = CL_ID INNER JOIN
    		dbo.DistrView WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR LEFT OUTER JOIN
			dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID LEFT OUTER JOIN
			dbo.SystemNetTable ON SN_ID = DF_ID_NET 
		WHERE SL_REST < 0        
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, SYS_ORDER

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_DEBT_SELECT] TO rl_report_debt_r;
GO
