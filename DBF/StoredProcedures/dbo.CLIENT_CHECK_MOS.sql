USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CHECK_MOS]
	@CL_ID	INT,
	@PR_ID	VARCHAR(MAX)
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

		IF OBJECT_ID('tempdb..#period') IS NOT NULL
			DROP TABLE #period

		CREATE TABLE #period(PRID SMALLINT PRIMARY KEY)

		INSERT INTO #period(PRID)
			SELECT Item
			FROM dbo.GET_TABLE_FROM_LIST(@PR_ID, ',')

		SELECT
			CL_ID, CL_PSEDO, PR_DATE, DIS_ID, DIS_STR, DS_NAME,
			z.SYS_SHORT_NAME + ' (' + REG_COMPLECT + ')' AS REG_COMPLECT,
			NULL AS BD_TOTAL_PRICE,
			AD_TOTAL_PRICE,
			CASE
				WHEN ACT_SIGN IS NULL THEN 'Нет'
				ELSE 'Да'
			END AS ACT_SIGN,
			ID_PRICE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT '№ ' + CONVERT(VARCHAR(20), IN_PAY_NUM) + ' от ' + CONVERT(VARCHAR(20), IN_DATE, 104) + ', '
					FROM
						(
							SELECT DISTINCT IN_DATE, IN_PAY_NUM
							FROM
								dbo.IncomeTable
								INNER JOIN dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
							WHERE ID_ID_DISTR = DIS_ID AND ID_ID_PERIOD = PR_ID AND IN_ID_CLIENT = CL_ID
						) AS o_O
					ORDER BY IN_DATE, IN_PAY_NUM FOR XML PATH('')
				)), 1, 2, '')) AS ID_NUM
		FROM
			dbo.ClientTable
			INNER JOIN dbo.TOTable ON TO_ID_CLIENT = CL_ID
			INNER JOIN dbo.PeriodRegTable ON REG_NUM_CLIENT = TO_NUM
			LEFT OUTER JOIN dbo.SystemTable z ON
					REG_COMPLECT LIKE SYS_REG_NAME + '#%'
					OR (REG_COMPLECT LIKE SYS_REG_NAME + '[0-9]%' AND CHARINDEX('#', REG_COMPLECT) = 0)
			INNER JOIN #period ON PRID = REG_ID_PERIOD
			INNER JOIN dbo.PeriodTable ON PR_ID = PRID
			INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON a.SYS_ID = REG_ID_SYSTEM AND DIS_NUM = REG_DISTR_NUM AND DIS_COMP_NUM = REG_COMP_NUM
			INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			LEFT OUTER JOIN
				(
					SELECT a.AD_ID_PERIOD, a.AD_ID_DISTR, a.AD_TOTAL_PRICE, ACT_SIGN
					FROM
						dbo.ActIXView a WITH(NOEXPAND)
						INNER JOIN #period ON PRID = AD_ID_PERIOD
						INNER JOIN dbo.ActTable b ON a.ACT_ID_CLIENT = b.ACT_ID_CLIENT
						INNER JOIN dbo.ActDistrTable c ON c.AD_ID_ACT = b.ACT_ID AND c.AD_ID_PERIOD = a.AD_ID_PERIOD AND c.AD_ID_DISTR = a.AD_ID_DISTR
					WHERE a.ACT_ID_CLIENT = @CL_ID
				) AS ACT ON AD_ID_DISTR = DIS_ID AND AD_ID_PERIOD = PR_ID
			LEFT OUTER JOIN
				(
					SELECT ID_ID_PERIOD, ID_ID_DISTR, ID_PRICE
					FROM
						dbo.IncomeIXView WITH(NOEXPAND)
						INNER JOIN #period ON ID_ID_PERIOD = PRID
					WHERE IN_ID_CLIENT = @CL_ID
				) AS INC ON ID_ID_DISTR = DIS_ID AND ID_ID_PERIOD = PR_ID
		WHERE CL_ID = @CL_ID
		ORDER BY PR_DATE DESC, a.SYS_ORDER, DIS_NUM

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
GRANT EXECUTE ON [dbo].[CLIENT_CHECK_MOS] TO rl_client_check;
GO
