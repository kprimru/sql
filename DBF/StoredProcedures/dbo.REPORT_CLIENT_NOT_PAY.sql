USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_CLIENT_NOT_PAY]
	@PERIOD	SMALLINT
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

		DECLARE @MON_CNT	TINYINT

		SET @MON_CNT = 3

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		CREATE TABLE #period
			(
				PR_ID	SMALLINT	PRIMARY KEY,
				PR_DATE	SMALLDATETIME
			)

		INSERT INTO #period(PR_ID, PR_DATE)
			SELECT PR_ID, PR_DATE
			FROM dbo.PeriodTable
			WHERE PR_DATE <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PERIOD)
				AND PR_DATE >= DATEADD(MONTH, -@MON_CNT + 1, (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PERIOD))

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				CL_ID		INT,
				CL_PSEDO	VARCHAR(50),
				DIS_ID		INT PRIMARY KEY,
				DIS_STR		VARCHAR(50),
				SYS_ORDER	INT,
				DIS_NUM		INT,
				DIS_COMP_NUM	TINYINT
			)

		INSERT INTO #distr(CL_ID, CL_PSEDO, DIS_ID, DIS_STR, SYS_ORDER, DIS_NUM, DIS_COMP_NUM)
			SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, SYS_ORDER, DIS_NUM, DIS_COMP_NUM
			FROM
				dbo.ClientDistrTable
				INNER JOIN dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
				INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR
				INNER JOIN dbo.ClientTable ON CL_ID = CD_ID_CLIENT
			WHERE DSS_REPORT = 1

		DELETE
		FROM #distr
		WHERE EXISTS
			(
				SELECT *
				FROM #period
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.BillIXView WITH(NOEXPAND)
						WHERE BL_ID_CLIENT = CL_ID
							AND BD_ID_DISTR = DIS_ID
							AND BL_ID_PERIOD = PR_ID
					)
			)

		SELECT
			CL_PSEDO, DIS_STR, PR_DATE,
			(
				SELECT TOP 1 ACT_DATE
				FROM
					dbo.ActTable
					INNER JOIN dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
				WHERE ACT_ID_CLIENT = CL_ID
					AND AD_ID_PERIOD = PR_ID
					AND AD_ID_DISTR = DIS_ID
			) AS ACT_DATE,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR)
				FROM
					dbo.InvoiceSaleTable a
					INNER JOIN dbo.InvoiceRowTable ON INS_ID = INR_ID_INVOICE
				WHERE INR_ID_DISTR = DIS_ID
					AND INR_ID_PERIOD = PR_ID
					AND INS_ID_CLIENT = CL_ID
			) AS INS_NUM,
			(
				SELECT MAX(PR_DATE)
				FROM
					dbo.BillRestView
					INNER JOIN dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
				WHERE BL_ID_CLIENT = CL_ID
					AND BD_ID_DISTR = DIS_ID
					AND BD_REST = 0
			) AS LAST_MONTH
		FROM
			#distr
			CROSS APPLY
				(
					SELECT PR_ID, PR_DATE
					FROM
						dbo.BillRestView
						INNER JOIN dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
					WHERE BL_ID_CLIENT = CL_ID
						AND BD_ID_DISTR = DIS_ID
						AND BD_REST <> 0
						AND PR_DATE <= @PR_DATE
				) AS a
			--CROSS JOIN #period a
		WHERE NOT EXISTS
				(
					SELECT *
					FROM
						dbo.BillRestView
						INNER JOIN #period ON BL_ID_PERIOD = PR_ID
					WHERE BL_ID_CLIENT = CL_ID
						AND BD_ID_DISTR = DIS_ID
						AND BD_REST = 0
				)
		ORDER BY CL_PSEDO, PR_DATE DESC, SYS_ORDER, DIS_NUM, DIS_COMP_NUM

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_CLIENT_NOT_PAY] TO rl_courier_pay;
GO
