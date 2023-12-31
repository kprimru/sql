USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_MONTH_STUDY_REPORT]
	@SH_ID	SMALLINT,
	@PR_MIN	SMALLINT,
	@PR_LIST	VARCHAR(MAX)
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

		DECLARE @PR_ID	SMALLINT

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		CREATE TABLE #period
			(
				TPR_ID SMALLINT PRIMARY KEY,
				TX_RATE	DECIMAL(8,4)
			)

		IF @PR_MIN IS NOT NULL
			INSERT INTO #period(TPR_ID, TX_RATE)
				SELECT PR_ID, TX_TAX_RATE
				FROM
					dbo.PeriodTable
					INNER JOIN Subhost.SubhostCalc ON PR_ID = SHC_ID_PERIOD
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE SHC_ID_SUBHOST = @SH_ID
					AND PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_MIN)
					AND PR_DATE >= '20111101'
		ELSE
			INSERT INTO #period(TPR_ID, TX_RATE)
				SELECT PR_ID, TX_TAX_RATE
				FROM
					dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
					INNER JOIN dbo.PeriodTable ON PR_ID = Item
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= '20111101'

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		CREATE TABLE #product
			(
				PR_ID		SMALLINT,
				SP_ID_GROUP	SMALLINT,
				SP_SUM		MONEY
			)

		INSERT INTO #product
			(PR_ID, SP_ID_GROUP, SP_SUM)
			SELECT
				TPR_ID, SP_ID_GROUP,
				SUM(CONVERT(MONEY,
					ROUND(SPP_PRICE * SPC_COUNT * (1 + ISNULL(SP_COEF, 0)/100), 2)
				))
			FROM
				#period
				INNER JOIN Subhost.SubhostProductCalc ON SPC_ID_PERIOD = TPR_ID
				INNER JOIN Subhost.SubhostProduct ON SP_ID = SPC_ID_PROD
				INNER JOIN Subhost.SubhostProductPrice ON SPP_ID_PRODUCT = SP_ID
													AND SPP_ID_PERIOD = TPR_ID
			WHERE SPC_ID_SUBHOST = @SH_ID
			GROUP BY TPR_ID, SP_ID_GROUP

		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		CREATE TABLE #pay
			(
				TPR_ID	SMALLINT,
				SHP_SUM	MONEY,
				SHP_DEBT	MONEY,
				SHP_PENALTY	MONEY,
				SHP_PERCENT	DECIMAL(10, 4),
				SHP_DAYS	SMALLINT
			)

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				SHP_DATE	INT,
				SHP_SUM		MONEY,
				SHP_SUM_PREV	MONEY,
				SHP_DEBT_OLD	MONEY,
				SHP_DEBT		MONEY,
				SHP_PENALTY		MONEY,
				SHP_PERCENT		DECIMAL(8, 4),
				SHP_DAYS	INT
			)

		SELECT @PR_ID = MIN(TPR_ID)
		FROM #period

		WHILE @PR_ID IS NOT NULL
		BEGIN
			DELETE FROM #tmp

			INSERT INTO #tmp
				EXEC Subhost.SUBHOST_SUM_SELECT @SH_ID, @PR_ID, 'STUDY'

			INSERT INTO #pay
				SELECT @PR_ID, SHP_SUM_PREV, SHP_DEBT, SHP_PENALTY, SHP_PERCENT, SHP_DAYS
				FROM #tmp

			SELECT @PR_ID = MIN(TPR_ID)
			FROM #period
			WHERE TPR_ID > @PR_ID
		END

		SELECT
			SHC_ID_PERIOD, PR_NAME, TX_RATE,
			SHC_INV_STUDY_DATE, SHC_INV_STUDY_NUM,
			(
				SELECT SP_SUM
				FROM #product a
				WHERE c.TPR_ID = a.PR_ID
					AND SP_ID_GROUP = 1
			) AS SP_10,
			(
				SELECT SP_SUM
				FROM #product a
				WHERE c.TPR_ID = a.PR_ID
					AND SP_ID_GROUP = 2
			) AS SP_STUDY,
			(
				SELECT SP_SUM
				FROM #product a
				WHERE c.TPR_ID = a.PR_ID
					AND SP_ID_GROUP = 3
			) AS SP_MARKET,
			(
				SELECT CONVERT(MONEY, SUM(ROUND(SS_COUNT * SLP_PRICE, 2)))
				FROM
					Subhost.SubhostStudy
					INNER JOIN Subhost.SubhostLessonPrice ON SLP_ID_PERIOD = SS_ID_PERIOD
												AND SLP_ID_LESSON = SS_ID_LESSON
				WHERE SS_ID_PERIOD = a.PR_ID
					AND SS_ID_SUBHOST = @SH_ID
			) AS SHP_STUDY,
			SHP_SUM, SHP_DEBT, SHP_PERCENT, SHP_DAYS, SHP_PENALTY
		FROM
			Subhost.SubhostCalc
			INNER JOIN #period c ON c.TPR_ID = SHC_ID_PERIOD
			INNER JOIN dbo.PeriodTable a ON PR_ID = TPR_ID
			LEFT OUTER JOIN #pay d ON d.TPR_ID = c.TPR_ID
		WHERE SHC_ID_SUBHOST = @SH_ID
		ORDER BY PR_DATE


		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		IF OBJECT_ID('tempdb..#product') IS NOT NULL
			DROP TABLE #product

		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_MONTH_STUDY_REPORT] TO rl_subhost_calc;
GO
