USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_EXCHANGE_SELECT]
	@DIS_ID	INT
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

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				SYS	VARCHAR(50),
				NET	VARCHAR(50),
				PR	SMALLINT
			)

		INSERT INTO #tmp(SYS, NET, PR)
			SELECT b.SYS_SHORT_NAME, g.SN_NAME, REG_ID_PERIOD
			FROM
				dbo.PeriodRegTable a
				INNER JOIN dbo.SystemTable b ON SYS_ID = REG_ID_SYSTEM
				INNER JOIN dbo.DistrTable c ON DIS_NUM = REG_DISTR_NUM AND DIS_COMP_NUM = REG_COMP_NUM
				INNER JOIN dbo.SystemTable e ON e.SYS_ID = c.DIS_ID_SYSTEM AND e.SYS_ID_HOST = b.SYS_ID_HOST
				INNER JOIN dbo.SystemNetCountTable f ON f.SNC_ID = REG_ID_NET
				INNER JOIN dbo.SystemNetTable g ON g.SN_ID = f.SNC_ID_SN
			WHERE DIS_ID = @DIS_ID

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID		SMALLINT IDENTITY(1, 1),
				RCOEF	VARCHAR(50),
				RNET	VARCHAR(50),
				RBEGIN	SMALLINT,
				REND	SMALLINT
			)

		DECLARE @ID	SMALLINT

		INSERT INTO #res(RCOEF, RNET, RBEGIN, REND)
			SELECT TOP 1 SYS, NET, PR_ID, NULL
			FROM
				#tmp
				INNER JOIN dbo.PeriodTable ON PR_ID = PR
			ORDER BY PR_DATE

		SELECT @ID = SCOPE_IDENTITY()

		DECLARE @PR_ID	SMALLINT

		SELECT @PR_ID = RBEGIN
		FROM #res

		WHILE @PR_ID IS NOT NULL
		BEGIN
			SET @PR_ID = dbo.PERIOD_NEXT(@PR_ID)

			IF
				(
					(SELECT RCOEF FROM #res WHERE ID = @ID) <> (SELECT SYS FROM #tmp WHERE PR = @PR_ID)
					OR
					(SELECT RNET FROM #res WHERE ID = @ID) <> (SELECT NET FROM #tmp WHERE PR = @PR_ID)
				)
			BEGIN
				UPDATE #res
				SET REND = dbo.PERIOD_PREV(@PR_ID)
				WHERE ID = @ID

				INSERT INTO #res(RCOEF, RNET, RBEGIN, REND)
					SELECT SYS, NET, PR, NULL
					FROM #tmp
					WHERE PR = @PR_ID

				SELECT @ID = SCOPE_IDENTITY()
			END
		END

		UPDATE #res
		SET REND =
			(
				SELECT PR_ID
				FROM dbo.PeriodTable
				WHERE PR_DATE =
					(
						SELECT MAX(PR_DATE)
						FROM
							dbo.PeriodTable
							INNER JOIN #tmp ON PR = PR_ID
					)
			)
		WHERE ID = @ID

		SELECT RCOEF AS SYS_SHORT_NAME, RNET AS SN_NAME, 'с ' + a.PR_NAME + ' по ' + b.PR_NAME AS RINTERVAL
		FROM
			#res
			INNER JOIN dbo.PeriodTable a ON a.PR_ID = RBEGIN
			INNER JOIN dbo.PeriodTable b ON b.PR_ID = REND
		ORDER BY a.PR_DATE


		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

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
GRANT EXECUTE ON [dbo].[DISTR_EXCHANGE_SELECT] TO rl_distr_financing_r;
GO
