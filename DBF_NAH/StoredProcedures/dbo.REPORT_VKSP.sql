USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REPORT_VKSP]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REPORT_VKSP]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[REPORT_VKSP]
	@Periods VARCHAR(MAX)
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

		DECLARE @PR_DATE SMALLDATETIME;
		DECLARE @DS_ID	SMALLINT;

		SELECT @PR_DATE = MIN(PR_DATE)
		FROM dbo.PeriodTable
		INNER JOIN dbo.GET_TABLE_FROM_LIST(@Periods, ',') ON PR_ID = Item

		SELECT @DS_ID = DS_ID
		FROM dbo.DistrStatusTable
		WHERE DS_REG = 0;

		DECLARE @PERIOD TABLE
		(
			PR_ID	SMALLINT PRIMARY KEY CLUSTERED,
			PR_DATE	SMALLDATETIME
		)

		INSERT INTO @PERIOD(PR_ID, PR_DATE)
		SELECT PR_ID, PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_DATE >= @PR_DATE
			AND EXISTS
				(
					SELECT *
					FROM dbo.PeriodRegTable
					WHERE PR_ID = REG_ID_PERIOD
				)


		DECLARE @RESULT TABLE
		(
			PR_ID					SMALLINT,
			PR_DATE					SMALLDATETIME PRIMARY KEY CLUSTERED,
			SYS_COUNT				INT,
			WEIGHT					DECIMAL(12, 4),
			WEIGHT_DELTA			DECIMAL(12, 4),
			WEIGHT_CORRECTION		DECIMAL(8, 4),
			WEIGHT_START			DECIMAL(12, 4),
			WEIGHT_FINISH			DECIMAL(12, 4),
			WEIGHT_MONTH_DELTA		DECIMAL(12, 4),
			WEIGHT_PERIOD_DELTA		DECIMAL(12, 4),
			WEIGHT_CORRECTION_SUM	DECIMAL(12, 4),
			WEIGHT_PERCENT			DECIMAL(8, 4)
		)

		INSERT INTO @RESULT(PR_ID, PR_DATE, SYS_COUNT, WEIGHT)
		SELECT PR_ID, PR_DATE, COUNT(*) AS CNT, SUM(b.WEIGHT)
		FROM @PERIOD p
		INNER JOIN dbo.PeriodRegTable a ON REG_ID_PERIOD = PR_ID
		INNER JOIN dbo.WeightRules b ON a.REG_ID_PERIOD = b.ID_PERIOD
									AND a.REG_ID_SYSTEM = b.ID_SYSTEM
									AND a.REG_ID_TYPE = b.ID_TYPE
									AND a.REG_ID_NET = b.ID_NET
		WHERE REG_ID_STATUS = @DS_ID AND WEIGHT <> 0
		GROUP BY PR_ID, PR_DATE

		UPDATE A
		SET WEIGHT_CORRECTION = B.WC_VALUE
		FROM @RESULT A
		INNER JOIN Ric.WeightCorrectionMonth B ON A.PR_ID = B.WC_ID_PERIOD

		UPDATE A
		SET WEIGHT_DELTA = A.WEIGHT - ISNULL((SELECT WEIGHT FROM @RESULT Z WHERE Z.PR_DATE = DATEADD(MONTH, -1, A.PR_DATE)), 0),
			WEIGHT_START = Ric.VKSPGet_New(DATEADD(MONTH, -12, A.PR_DATE)),
			WEIGHT_FINISH = Ric.VKSPGet_New(A.PR_DATE),
			WEIGHT_CORRECTION_SUM =
				(
					SELECT SUM(WC_VALUE)
					FROM
						Ric.WeightCorrectionMonth Z
						INNER JOIN dbo.PeriodTable Y ON Y.PR_ID = Z.WC_ID_PERIOD
					WHERE Y.PR_DATE BETWEEN DATEADD(MONTH, -11, A.PR_DATE) AND A.PR_DATE
				)
		FROM @RESULT A

		UPDATE A
		SET WEIGHT_MONTH_DELTA = WEIGHT_DELTA,
			WEIGHT_PERIOD_DELTA = WEIGHT_FINISH - WEIGHT_START
		FROM @RESULT A

		UPDATE A
		SET WEIGHT_PERCENT = 100 * (WEIGHT_PERIOD_DELTA + ISNULL(WEIGHT_CORRECTION_SUM, 0)) / NullIf(WEIGHT_START, 0)
		FROM @RESULT A

		SELECT
			[Номер строки]							= ROW_NUMBER() OVER(ORDER BY PR_DATE),
			[Дата]									= PR_DATE,
			[Кол-во весовых систем] 				= SYS_COUNT,
			[Вес]									= WEIGHT,
			[Прирост веса]							= WEIGHT_DELTA,
			[Весовая поправка]						= WEIGHT_CORRECTION,
			[Период П4|Вес на начало]				= WEIGHT_START,
			[Период П4|Вес на конец]				= WEIGHT_FINISH,
			[Период П4|Прирост веса за месяц]		= WEIGHT_MONTH_DELTA,
			[Период П4|Прирост веса за период]		= WEIGHT_PERIOD_DELTA,
			[Период П4|Весовая поправка]			= WEIGHT_CORRECTION_SUM,
			[Период П4|Прирост веса за период %]	= WEIGHT_PERCENT
		FROM @RESULT A
		ORDER BY PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_VKSP] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_VKSP] TO rl_reg_report_r;
GO
