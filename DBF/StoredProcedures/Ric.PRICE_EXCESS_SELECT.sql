USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[PRICE_EXCESS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Ric].[PRICE_EXCESS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Ric].[PRICE_EXCESS_SELECT]
	@PR_ALG	SMALLINT,
	@PR_ID	SMALLINT,
	@PRICE	VARCHAR(MAX)
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

		IF OBJECT_ID('tempdb..#price') IS NOT NULL
			DROP TABLE #price

		CREATE TABLE #price
			(
				SYS_ID		SMALLINT,
				PRICE_HOST	MONEY,
				PRICE_VMI	MONEY
			)

		DECLARE @RES DECIMAL(10, 4)

		DECLARE @XML XML

		SET @XML = CAST(@PRICE AS XML)

		DECLARE @SQL NVARCHAR(MAX)

		INSERT INTO #price(SYS_ID, PRICE_HOST, PRICE_VMI)
			SELECT
				c.value('(@SYS)', 'SMALLINT'),
				c.value('(@HOST)', 'MONEY'),
				c.value('(@VMI)', 'MONEY')
			FROM @xml.nodes('/LIST/ITEM') AS a(c)

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #price (SYS_ID)'
		EXEC (@SQL)


		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @REC	MONEY
		DECLARE	@CALC	MONEY

		DECLARE @SYS_LIST	VARCHAR(MAX)
		SET @SYS_LIST = ''

		IF @PR_DATE >= '20100101'
		BEGIN
			SELECT @SYS_LIST = @SYS_LIST + CONVERT(VARCHAR(20), SYS_ID) + ','
			FROM dbo.SystemTable
			WHERE SYS_REG_NAME IN
				('LAW', 'BUHL', 'ROS', 'QSA', 'FIN', 'ARB', 'PAP', 'CMT', 'KOR', 'EXP')

			SET @SYS_LIST = LEFT(@SYS_LIST, LEN(@SYS_LIST) - 1)

			SELECT @REC = SUM(PRICE_VMI * SNCC_VALUE)
			FROM
				dbo.PeriodRegExceptView
				INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
				INNER JOIN dbo.GET_TABLE_FROM_LIST(@SYS_LIST, ',') ON Item = REG_ID_SYSTEM
				INNER JOIN
					(
						SELECT SNC_ID, SN_ID, SN_NAME, SNCC_VALUE
						FROM
							dbo.SystemNetCountTable
							INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
							INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
						WHERE SNCC_ID_PERIOD = @PR_ID
					) AS g ON SNC_ID = REG_ID_NET
				INNER JOIN #price ON SYS_ID = REG_ID_SYSTEM
			WHERE REG_ID_PERIOD = @PR_ID AND DS_REG = 0

			SELECT @CALC = SUM(PRICE_HOST * SNCC_VALUE * TTP_COEF)
			FROM
				dbo.PeriodRegExceptView
				INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
				INNER JOIN dbo.GET_TABLE_FROM_LIST(@SYS_LIST, ',') ON Item = REG_ID_SYSTEM
				INNER JOIN
					(
						SELECT SNC_ID, SN_ID, SN_NAME, SNCC_VALUE
						FROM
							dbo.SystemNetCountTable
							INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
							INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
						WHERE SNCC_ID_PERIOD = @PR_ID
					) AS g ON SNC_ID = REG_ID_NET
				INNER JOIN #price ON SYS_ID = REG_ID_SYSTEM
			WHERE REG_ID_PERIOD = @PR_ID AND DS_REG = 0

			SET @RES = ROUND((@CALC / @REC - 1) * 100, 2)
		END

		SELECT @RES AS EXCESS, Ric.PriceExcessCoefGet(@PR_ALG, @RES) AS EXCESS_COEF

		IF OBJECT_ID('tempdb..#price') IS NOT NULL
			DROP TABLE #price

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[PRICE_EXCESS_SELECT] TO rl_price_calc;
GO
