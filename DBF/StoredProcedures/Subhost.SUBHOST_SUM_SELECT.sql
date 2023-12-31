USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_SUM_SELECT]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@TYPE	VARCHAR(10)
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

		DECLARE @TX_RATE DECIMAL(8,4)

		DECLARE @DATE SMALLDATETIME
		DECLARE @PREV_DATE	SMALLDATETIME

		SELECT @DATE = SCD_DATE
		FROM Subhost.SubhostCalcDates
		WHERE SCD_ID_PERIOD = @PR_ID

		IF @DATE IS NULL
			SELECT @DATE = DATEADD(DAY, 9, PR_DATE)
			FROM dbo.PeriodTable
			WHERE PR_ID = @PR_ID

		SELECT @PREV_DATE = SCD_DATE
		FROM Subhost.SubhostCalcDates
		WHERE SCD_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)

		IF @PREV_DATE IS NULL
			SET @PREV_DATE = DATEADD(MONTH, -1, @DATE)

		DECLARE @PREV SMALLINT

		SELECT @PREV = dbo.PERIOD_PREV(@PR_ID)

		SELECT @TX_RATE = TX_TOTAL_RATE
		FROM dbo.PeriodTable
		CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
		WHERE PR_ID = @PREV

		DECLARE @ORG_ID SMALLINT
		DECLARE @ORG_ID_STUDY SMALLINT
		DECLARE @ORG_ID_SERVICE SMALLINT

		IF @TYPE = 'STUDY'
			SELECT @ORG_ID = SCS_ID_ORG_STUDY
			FROM Subhost.SubhostCalcSettings
		ELSE IF @TYPE = 'SERVICE'
			SELECT @ORG_ID = SCS_ID_ORG_SERVICE
			FROM Subhost.SubhostCalcSettings

			SELECT @ORG_ID_STUDY = SCS_ID_ORG_STUDY
			FROM Subhost.SubhostCalcSettings
			SELECT @ORG_ID_SERVICE = SCS_ID_ORG_SERVICE
			FROM Subhost.SubhostCalcSettings

		DECLARE @TOTAL	MONEY
		DECLARE @TOTAL_PREV	MONEY

		DECLARE	@PAY	MONEY
		DECLARE @PAY_PREV	MONEY

		SELECT @TOTAL =
			CASE @TYPE
				WHEN 'STUDY' THEN SHC_TOTAL_STUDY
				WHEN 'SERVICE' THEN SHC_TOTAL
				ELSE 0
			END
		FROM Subhost.SubhostCalc
		WHERE SHC_ID_PERIOD = @PR_ID
			AND SHC_ID_SUBHOST = @SH_ID
		/*
		SELECT @TOTAL_PREV =
			CASE @TYPE
				WHEN 'STUDY' THEN
					CASE
						WHEN @SH_ID = 3 AND @PR_ID = 272 THEN (SELECT SCR_IC + SCR_IC_NDS + SCR_IC_DEBT + SCR_IC_PENALTY FROM Subhost.SubhostCalcReport WHERE SCR_ID_SUBHOST = @SH_ID AND SCR_ID_PERIOD = @PREV)
					ELSE SHC_TOTAL_STUDY
					END
				WHEN 'SERVICE' THEN SHC_TOTAL
				ELSE 0
			END
		FROM Subhost.SubhostCalc
		WHERE SHC_ID_PERIOD = @PREV
			AND SHC_ID_SUBHOST = @SH_ID
			*/

		DECLARE @TOTAL_PREV_STUDY MONEY
		DECLARE @TOTAL_PREV_SERVICE MONEY

		IF EXISTS
			(
				SELECT *
				FROM Subhost.SubhostCalcReport
				WHERE SCR_ID_SUBHOST = @SH_ID
					AND SCR_ID_PERIOD = @PREV
			)
			SELECT @TOTAL_PREV =
				CASE @TYPE
					WHEN 'STUDY' THEN SCR_IC + SCR_IC_NDS + SCR_IC_DEBT + SCR_IC_PENALTY + CASE WHEN @PR_ID = 306 AND @SH_ID = 3 THEN 8444.60 ELSE 0 END
					WHEN 'SERVICE' THEN SCR_TOTAL
					ELSE 0
				END
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_PERIOD = @PREV
				AND SCR_ID_SUBHOST = @SH_ID
		ELSE
			SELECT @TOTAL_PREV =
				CASE @TYPE
					WHEN 'STUDY' THEN
						CASE
							WHEN @SH_ID = 3 AND @PR_ID = 272 THEN (SELECT SCR_IC + SCR_IC_NDS + SCR_IC_DEBT + SCR_IC_PENALTY FROM Subhost.SubhostCalcReport WHERE SCR_ID_SUBHOST = @SH_ID AND SCR_ID_PERIOD = @PREV)
						ELSE SHC_TOTAL_STUDY
						END
					WHEN 'SERVICE' THEN SHC_TOTAL
					ELSE 0
				END
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PREV
				AND SHC_ID_SUBHOST = @SH_ID

		IF EXISTS
			(
				SELECT *
				FROM Subhost.SubhostCalcReport
				WHERE SCR_ID_SUBHOST = @SH_ID
					AND SCR_ID_PERIOD = @PREV
			)
		BEGIN
			SELECT @TOTAL_PREV_STUDY = SCR_IC + SCR_IC_NDS + SCR_IC_DEBT + SCR_IC_PENALTY
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_PERIOD = @PREV
				AND SCR_ID_SUBHOST = @SH_ID

			SELECT @TOTAL_PREV_SERVICE = SCR_TOTAL
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_PERIOD = @PREV
				AND SCR_ID_SUBHOST = @SH_ID
		END
		ELSE
		BEGIN
			SELECT @TOTAL_PREV_STUDY =
						CASE
							WHEN @SH_ID = 3 AND @PR_ID = 272 THEN (SELECT SCR_IC + SCR_IC_NDS + SCR_IC_DEBT + SCR_IC_PENALTY FROM Subhost.SubhostCalcReport WHERE SCR_ID_SUBHOST = @SH_ID AND SCR_ID_PERIOD = @PREV)
						END
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PREV
				AND SHC_ID_SUBHOST = @SH_ID

			SELECT @TOTAL_PREV_SERVICE = SHC_TOTAL
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PREV
				AND SHC_ID_SUBHOST = @SH_ID
		END

		IF @TOTAL_PREV = 0 AND @TYPE = 'SERVICE'
			SELECT @TOTAL_PREV = SCR_TOTAL_NDS
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_SUBHOST = @SH_ID
				AND SCR_ID_PERIOD = @PREV

		IF @TOTAL_PREV_SERVICE = 0
			SELECT @TOTAL_PREV_SERVICE = SCR_TOTAL_NDS
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_SUBHOST = @SH_ID
				AND SCR_ID_PERIOD = @PREV

		IF @TOTAL_PREV = 0 AND @TYPE = 'STUDY'
			/*
			SELECT @TOTAL_PREV = SHC_TOTAL_STUDY
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PREV
				AND SHC_ID_SUBHOST = @SH_ID
			*/
			SELECT @TOTAL_PREV =
				ROUND((
					SELECT SUM(SS_COUNT * SLP_PRICE)
					FROM
						Subhost.SubhostStudy a INNER JOIN
						Subhost.SubhostLessonPrice b ON a.SS_ID_PERIOD = b.SLP_ID_PERIOD
											AND SS_ID_LESSON = SLP_ID_LESSON
					WHERE SLP_ID_PERIOD = @PREV AND SS_ID_SUBHOST = @SH_ID
				) * @TX_RATE, 2)

		IF @TOTAL_PREV_STUDY = 0
			/*
			SELECT @TOTAL_PREV = SHC_TOTAL_STUDY
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PREV
				AND SHC_ID_SUBHOST = @SH_ID
			*/
			SELECT @TOTAL_PREV_STUDY =
				ROUND((
					SELECT SUM(SS_COUNT * SLP_PRICE)
					FROM
						Subhost.SubhostStudy a INNER JOIN
						Subhost.SubhostLessonPrice b ON a.SS_ID_PERIOD = b.SLP_ID_PERIOD
											AND SS_ID_LESSON = SLP_ID_LESSON
					WHERE SLP_ID_PERIOD = @PREV AND SS_ID_SUBHOST = @SH_ID
				) * @TX_RATE, 2)

		IF @PR_ID = 307 AND @SH_ID = 3 AND @TYPE = 'STUDY'
		BEGIN
			SELECT @TOTAL_PREV = SHC_TOTAL_STUDY
			FROM Subhost.SubhostCalc
			WHERE SHC_ID_PERIOD = @PREV
				AND SHC_ID_SUBHOST = @SH_ID
		END


		SELECT @PAY = SUM(SPD_SUM)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SHP_ID = SPD_ID_PAY
		WHERE SHP_ID_SUBHOST = @SH_ID
			AND SHP_DATE > @PREV_DATE--CASE @PREV_DATE WHEN '20141210' THEN '20141203' ELSE @PREV_DATE END
			AND SHP_DATE <= @DATE
			AND SHP_ID_ORG = @ORG_ID

		DECLARE @PAY_ALL MONEY

		SELECT @PAY_ALL = SUM(SPD_SUM)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SHP_ID = SPD_ID_PAY
		WHERE SHP_ID_SUBHOST = @SH_ID
			AND SHP_DATE > @PREV_DATE--CASE @PREV_DATE WHEN '20141210' THEN '20141203' ELSE @PREV_DATE END
			AND SHP_DATE <= @DATE
			--AND SHP_ID_ORG = @ORG_ID

		DECLARE @DEBT MONEY

		SET @DEBT = @TOTAL_PREV -
			ISNULL((SELECT SUM(SPD_SUM)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SHP_ID = SPD_ID_PAY
		WHERE /*SPD_ID_PERIOD = @PREV*/
			SHP_DATE > @PREV_DATE
			AND SHP_ID_SUBHOST = @SH_ID
			AND SHP_DATE <= @DATE
			AND SHP_ID_ORG = @ORG_ID), 0)

		SET @DEBT = ISNULL(@DEBT, 0)

		IF (@SH_ID = 12 AND @PR_ID = 292) OR (@SH_ID = 3 AND @PR_ID = 295) OR (@SH_ID = 8 AND @PR_ID = 303) OR (@SH_ID = 3 AND @PR_ID = 314)
			SET @DEBT = 0

		IF (@SH_ID = 11 AND @PR_ID = 316) AND @TYPE = 'STUDY'
			SET @DEBT = 0


		DECLARE @DEBT_ALL MONEY

		SET @DEBT_ALL = @TOTAL_PREV_STUDY + @TOTAL_PREV_SERVICE -
			ISNULL((SELECT SUM(SPD_SUM)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SHP_ID = SPD_ID_PAY
		WHERE /*SPD_ID_PERIOD = @PREV*/
			SHP_DATE > @PREV_DATE
			AND SHP_ID_SUBHOST = @SH_ID
			AND SHP_DATE <= @DATE
			), 0)

		IF @PR_ID = 307 AND @SH_ID = 3 AND @TYPE = 'SERVICE'
		BEGIN
			SELECT @DEBT_ALL = @DEBT
		END

		--IF @DEBT < 0
		--	SET @DEBT = 0

		DECLARE @LAST_DATE SMALLDATETIME
		DECLARE @LAST_DATE_STUDY SMALLDATETIME
		DECLARE @LAST_DATE_SERVICE SMALLDATETIME

		SELECT @LAST_DATE = MAX(SHP_DATE)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SPD_ID_PAY = SHP_ID
		WHERE SHP_ID_SUBHOST = @SH_ID AND SPD_ID_PERIOD = @PREV
			AND SHP_DATE > @PREV_DATE
			AND SHP_ID_ORG = @ORG_ID

		SELECT @LAST_DATE_STUDY = MAX(SHP_DATE)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SPD_ID_PAY = SHP_ID
		WHERE SHP_ID_SUBHOST = @SH_ID AND SPD_ID_PERIOD = @PREV
			AND SHP_DATE > @PREV_DATE
			AND SHP_ID_ORG = @ORG_ID_STUDY

		SELECT @LAST_DATE_SERVICE = MAX(SHP_DATE)
		FROM
			Subhost.SubhostPay
			INNER JOIN Subhost.SubhostPayDetail ON SPD_ID_PAY = SHP_ID
		WHERE SHP_ID_SUBHOST = @SH_ID AND SPD_ID_PERIOD = @PREV
			AND SHP_DATE > @PREV_DATE
			AND SHP_ID_ORG = @ORG_ID_SERVICE

		DECLARE @DAYS INT

		SET @DAYS = DATEDIFF(DAY, @DATE, @LAST_DATE)

		IF ISNULL(@DAYS, 0) <= 0
			SET @DAYS = 0

		IF @SH_ID = 12 AND @PR_ID = 354 AND @TYPE = 'SERVICE'
			SET @DAYS = 22;

		DECLARE @PERCENT DECIMAL(8, 4)

		SELECT @PERCENT = SH_PENALTY
		FROM dbo.SubhostTable
		WHERE SH_ID = @SH_ID

		DECLARE @PERIODICITY SMALLINT

		SELECT @PERIODICITY = SH_PERIODICITY
		FROM dbo.SubhostTable
		WHERE SH_ID = @SH_ID

		DECLARE @PENALTY MONEY

		/*
		SET @PENALTY =
			ISNULL((
				SELECT SUM(ROUND(SERVICE_DEBT * SHP_PERCENT / 100 * SHP_DAYS, 2))
				FROM
					(
						SELECT
							SERVICE_DEBT,
							CASE @PERIODICITY
								WHEN 0 THEN
									CASE
										WHEN DATEDIFF(DAY, SHP_DATE, PREV_DATE) <= 0 THEN 0
										ELSE 1
									END
								ELSE
									CASE
										WHEN DATEDIFF(DAY, SHP_DATE, PREV_DATE) <= 0 THEN 0
										ELSE DATEDIFF(DAY, SHP_DATE, PREV_DATE) / @PERIODICITY
									END
							END AS SHP_DAYS,
							@PERCENT AS SHP_PERCENT
						FROM
							(
								SELECT DISTINCT
									/*
									SHP_ID_ORG, */CASE WHEN SHP_DATE < @DATE THEN @DATE ELSE SHP_DATE END AS SHP_DATE,-- @TOTAL_PREV_STUDY, @TOTAL_PREV_SERVICE,
									@TOTAL_PREV_SERVICE -
										ISNULL((
											SELECT SUM(SHP_SUM)
											FROM Subhost.SubhostPay z
											WHERE z.SHP_ID_SUBHOST = @SH_ID
												AND z.SHP_DATE > @PREV_DATE
												AND z.SHP_DATE <= a.SHP_DATE
												AND z.SHP_ID_ORG = @ORG_ID_SERVICE
										),0) AS SERVICE_DEBT,
									ISNULL(
										(
											SELECT TOP 1 SHP_DATE
											FROM Subhost.SubhostPay z
											WHERE z.SHP_ID_SUBHOST = @SH_ID
												AND z.SHP_DATE > a.SHP_DATE
												--AND z.SHP_DATE > @PREV_DATE
												AND z.SHP_ID_ORG = @ORG_ID_SERVICE
											ORDER BY SHP_DATE
										)
									, GETDATE()) AS PREV_DATE
								FROM Subhost.SubhostPay a
								WHERE SHP_ID_SUBHOST = @SH_ID
									AND SHP_DATE > @PREV_DATE
									AND SHP_ID_ORG = @ORG_ID_SERVICE
							) AS o_O
					) AS o_O
			), 0)
			+
			ISNULL(
				(
					SELECT SUM(ROUND(SERVICE_DEBT * SHP_PERCENT / 100 * SHP_DAYS, 2))
					FROM
						(
							SELECT
								SERVICE_DEBT,
								CASE @PERIODICITY
									WHEN 0 THEN
										CASE
											WHEN DATEDIFF(DAY, SHP_DATE, PREV_DATE) <= 0 THEN 0
											ELSE 1
										END
									ELSE
										CASE
											WHEN DATEDIFF(DAY, SHP_DATE, PREV_DATE) <= 0 THEN 0
											ELSE DATEDIFF(DAY, SHP_DATE, PREV_DATE) / @PERIODICITY
										END
								END AS SHP_DAYS,
								@PERCENT AS SHP_PERCENT
							FROM
								(
									SELECT DISTINCT
										/*
										SHP_ID_ORG, */CASE WHEN SHP_DATE < @DATE THEN @DATE ELSE SHP_DATE END AS SHP_DATE,-- @TOTAL_PREV_STUDY, @TOTAL_PREV_SERVICE,
										@TOTAL_PREV_STUDY -
											ISNULL((
												SELECT SUM(SHP_SUM)
												FROM Subhost.SubhostPay z
												WHERE z.SHP_ID_SUBHOST = @SH_ID
													AND z.SHP_DATE > @PREV_DATE
													AND z.SHP_DATE <= a.SHP_DATE
													AND z.SHP_ID_ORG = @ORG_ID_STUDY
											),0) AS SERVICE_DEBT,
										ISNULL(
											(
												SELECT TOP 1 SHP_DATE
												FROM Subhost.SubhostPay z
												WHERE z.SHP_ID_SUBHOST = @SH_ID
													AND z.SHP_DATE > a.SHP_DATE
													AND z.SHP_ID_ORG = @ORG_ID_STUDY
													--AND z.SHP_DATE > @PREV_DATE
												ORDER BY SHP_DATE
											)
										, GETDATE()) AS PREV_DATE
									FROM Subhost.SubhostPay a
									WHERE SHP_ID_SUBHOST = @SH_ID
										AND SHP_DATE > @PREV_DATE
										AND SHP_ID_ORG = @ORG_ID_STUDY
								) AS o_O
						) AS o_O
				), 0)
		*/

		SET @PENALTY =
			ISNULL((
				SELECT SUM(ROUND(SERVICE_DEBT * SHP_PERCENT / 100 * SHP_DAYS, 2))
				FROM
					(
						SELECT
							@DEBT AS SERVICE_DEBT,
							CASE @PERIODICITY
								WHEN 0 THEN
									CASE @DAYS
										WHEN 0 THEN 0
										ELSE 1
									END
								ELSE @DAYS / @PERIODICITY
							END AS SHP_DAYS,
							@PERCENT AS SHP_PERCENT
					) AS o_O
			), 0)

		IF @PENALTY <= 0
			SET @PENALTY = 0

		IF @SH_ID = 3 AND @PR_ID = 307 AND @TYPE = 'SERVICE'
			SET @PENALTY = 0

		IF @SH_ID = 11 AND @PR_ID = 309 AND @TYPE = 'SERVICE'
			SET @PENALTY = 0

		IF @SH_ID = 11 AND @PR_ID = 309 AND @TYPE = 'STUDY'
			--SET @DEBT = -70.8
			SET @DEBT = 0

		IF @SH_ID = 12 AND @PR_ID = 330 AND @TYPE = 'SERVICE'
			SET @PENALTY = 364.48

		IF @SH_ID = 3 AND @PR_ID = 335 AND @TYPE = 'STUDY'
			--SET @DEBT = -70.8
			SET @DEBT = 0

		IF @SH_ID = 3 AND @PR_ID = 335 AND @TYPE = 'SERVICE'
			--SET @DEBT = -70.8
			--SET @PENALTY = 0.03
			SET @PENALTY = 0

		IF @SH_ID = 11 AND @PR_ID = 339 AND @TYPE = 'SERVICE'
			--SET @DEBT = -70.8
			--SET @PENALTY = 0.03
			SET @PENALTY = 0

		--SELECT @PAY_PREV, @DEBT, @LAST_DATE, @DAYS
		SELECT
			DATEPART(DAY, @DATE) AS SHP_DATE,
			ISNULL(@TOTAL, 0) AS SHP_SUM,
			ISNULL(@PAY, 0) AS SHP_SUM_PREV,
			ISNULL(@DEBT, 0)	AS SHP_DEBT_OLD,
			ISNULL(@DEBT, 0)	AS SHP_DEBT,
			CASE @TYPE WHEN 'STUDY' THEN 0 ELSE
			--ROUND(ISNULL(@DEBT_ALL, 0) * @PERCENT / 100.0 * @DAYS / @PERIODICITY, 2) END AS SHP_PENALTY,
			@PENALTY END AS SHP_PENALTY,
			@PERCENT AS SHP_PERCENT,
			CASE @PERIODICITY
				WHEN 0 THEN
					CASE @DAYS
						WHEN 0 THEN 0
						ELSE 1
					END
				ELSE @DAYS / @PERIODICITY
			END AS SHP_DAYS

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_SUM_SELECT] TO rl_subhost_calc;
GO
