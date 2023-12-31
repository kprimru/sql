USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_YEAR_STUDY_REPORT]
	@PR_MIN	SMALLINT,
	@PR_LIST	VARCHAR(MAX) = NULL
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
		DECLARE @SUB_ID SMALLINT

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		CREATE TABLE #period
			(
				TPR_ID	SMALLINT PRIMARY KEY,
				TX_TOTAL_RATE	DECIMAL(8,4)
			)

		IF @PR_MIN IS NOT NULL
			INSERT INTO #period(TPR_ID, TX_TOTAL_RATE)
				SELECT DISTINCT PR_ID, TX_TOTAL_RATE
				FROM
					dbo.PeriodTable
					INNER JOIN Subhost.SubhostCalc ON PR_ID = SHC_ID_PERIOD
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_MIN)
					AND PR_DATE >= '20111101'
		ELSE
			INSERT INTO #period(TPR_ID, TX_TOTAL_RATE)
				SELECT PR_ID, TX_TOTAL_RATE
				FROM
					dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
					INNER JOIN dbo.PeriodTable ON PR_ID = Item
					CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
				WHERE PR_DATE >= '20111101'


		IF OBJECT_ID('tempdb..#pay') IS NOT NULL
			DROP TABLE #pay

		CREATE TABLE #pay
			(
				SH_ID	SMALLINT,
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
			SET @SUB_ID = NULL

			SELECT @SUB_ID = MIN(SHC_ID_SUBHOST)
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PR_ID

			WHILE @SUB_ID IS NOT NULL
			BEGIN
				DELETE FROM #tmp

				INSERT INTO #tmp
					EXEC Subhost.SUBHOST_SUM_SELECT @SUB_ID, @PR_ID, 'STUDY'

				INSERT INTO #pay
					SELECT @SUB_ID, @PR_ID, SHP_SUM_PREV, SHP_DEBT, SHP_PENALTY, SHP_PERCENT, SHP_DAYS
					FROM #tmp

				SELECT @SUB_ID = MIN(SHC_ID_SUBHOST)
				FROM Subhost.SubhostCalc
				WHERE SHC_ID_PERIOD = @PR_ID AND SHC_ID_SUBHOST > @SUB_ID
			END

			SELECT @PR_ID = MIN(TPR_ID)
			FROM #period
			WHERE TPR_ID > @PR_ID
		END

		SELECT
			ROW_NUMBER() OVER(PARTITION BY SH_ORDER ORDER BY SH_ORDER, PR_DATE) AS RN,
			SHC_ID_SUBHOST, SH_FULL_NAME, SH_ORDER, SHC_ID_PERIOD, PR_NAME, PR_DATE,
			ISNULL(SHP_STUDY, 0) AS SHP_STUDY,
			ISNULL(SHP_STUDY, 0) AS TOTAL,
			CONVERT(MONEY, ROUND((ISNULL(SHP_STUDY, 0)) * TX_TOTAL_RATE, 2)) AS TOTAL_NDS,
			(
				SELECT SHP_SUM
				FROM #pay
				WHERE TPR_ID = SHC_ID_PERIOD
					AND SH_ID = SHC_ID_SUBHOST
			) AS PAY,
			(
				SELECT SHP_DEBT
				FROM #pay
				WHERE TPR_ID = SHC_ID_PERIOD
					AND SH_ID = SHC_ID_SUBHOST
			) AS DEBT,
			(
				SELECT SHP_PENALTY
				FROM #pay
				WHERE TPR_ID = SHC_ID_PERIOD
					AND SH_ID = SHC_ID_SUBHOST
			) AS PENALTY
		FROM
			(
				SELECT
					SS_ID AS SHC_ID_SUBHOST, SH_FULL_NAME, SH_ORDER,
					PR_ID AS SHC_ID_PERIOD, PR_NAME, PR_DATE, TX_TOTAL_RATE,
					(
						SELECT CONVERT(MONEY, SUM(ROUND(SS_COUNT * SLP_PRICE, 2)))
						FROM
							Subhost.SubhostStudy
							INNER JOIN Subhost.SubhostLessonPrice ON SLP_ID_PERIOD = SS_ID_PERIOD
														AND SLP_ID_LESSON = SS_ID_LESSON
						WHERE SS_ID_PERIOD = a.PR_ID
							AND SS_ID_SUBHOST = t.SH_ID
							AND SS_ID_SUBHOST = SHC_ID_SUBHOST
					) AS SHP_STUDY,
					SHP_SUM, SHP_DEBT, SHP_PERCENT, SHP_DAYS, SHP_PENALTY
				FROM
					#period c
					CROSS JOIN
					(
						SELECT DISTINCT SHC_ID_SUBHOST AS SS_ID
						FROM
							Subhost.SubhostCalc
							--INNER JOIN #period ON TPR_ID = SHC_ID_PERIOD
					) AS dt
					LEFT OUTER JOIN	Subhost.SubhostCalc ON c.TPR_ID = SHC_ID_PERIOD AND SHC_ID_SUBHOST = SS_ID
					LEFT OUTER JOIN dbo.PeriodTable a ON PR_ID = TPR_ID
					LEFT OUTER JOIN dbo.SubhostTable t ON t.SH_ID = SS_ID--SHC_ID_SUBHOST
					LEFT OUTER JOIN #pay d ON d.TPR_ID = c.TPR_ID AND d.SH_ID = t.SH_ID
			) AS o_O
		--WHERE SHC_ID_SUBHOST IS NOT NULL
		ORDER BY SH_ORDER, PR_DATE


		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

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
GRANT EXECUTE ON [Subhost].[SUBHOST_YEAR_STUDY_REPORT] TO rl_subhost_calc;
GO
