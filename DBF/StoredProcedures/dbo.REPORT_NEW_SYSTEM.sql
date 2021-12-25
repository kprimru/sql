USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_NEW_SYSTEM]
	@subhostlist VARCHAR(MAX),
	@systemlist VARCHAR(MAX),
	@systemtypelist VARCHAR(MAX),
	@systemnetlist VARCHAR(MAX),
	@periodlist VARCHAR(MAX),
	@techtypelist VARCHAR(MAX),
	@selecttotal BIT
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

		--Шаг 0. Разобрать строку и выделить из нее все идентификаторы. По строке на таблицу.

		IF OBJECT_ID('tempdb..#dbf_system') IS NOT NULL
			DROP TABLE #dbf_system

		CREATE TABLE #dbf_system
			(
				TSYS_ID INT NOT NULL,
				HST_ID	INT
			)

		IF @systemlist IS NULL
		BEGIN
			INSERT INTO #dbf_system
				SELECT SYS_ID, SYS_ID_HOST
				FROM dbo.SystemTable
				WHERE SYS_REPORT = 1
		END
		ELSE
		BEGIN

			INSERT INTO #dbf_system (TSYS_ID, HST_ID)
				SELECT SYS_ID, SYS_ID_HOST
				FROM
					dbo.GET_TABLE_FROM_LIST(@systemlist, ',')
					INNER JOIN dbo.SystemTable ON SYS_ID = Item
		END


		IF OBJECT_ID('tempdb..#dbf_systemtype') IS NOT NULL
			DROP TABLE #dbf_systemtype

		CREATE TABLE #dbf_systemtype
			(
				TST_ID INT NOT NULL
			)

		IF @systemtypelist IS NULL
		BEGIN
			INSERT INTO #dbf_systemtype
				SELECT SST_ID
				FROM dbo.SystemTypeTable
				WHERE SST_REPORT = 1
		END
		ELSE
		BEGIN
			INSERT INTO #dbf_systemtype
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@systemtypelist, ',')
		END

		IF OBJECT_ID('tempdb..#dbf_subhost') IS NOT NULL
			DROP TABLE #dbf_subhost

		CREATE TABLE #dbf_subhost
			(
				TSH_ID INT NOT NULL
			)

		IF @subhostlist IS NULL
		BEGIN
			INSERT INTO #dbf_subhost
				SELECT SH_ID
				FROM dbo.SubhostTable
				WHERE SH_ACTIVE = 1
		END
		ELSE
		BEGIN
			INSERT INTO #dbf_subhost
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@subhostlist, ',')
		END

		IF OBJECT_ID('tempdb..#dbf_systemnet') IS NOT NULL
			DROP TABLE #dbf_systemnet

		CREATE TABLE #dbf_systemnet
			(
				TSN_ID INT NOT NULL
			)

		IF @systemnetlist IS NULL
		BEGIN
			INSERT INTO #dbf_systemnet
				SELECT SN_ID
				FROM dbo.SystemNetTable
				WHERE SN_ACTIVE = 1
				ORDER BY SN_ORDER
		END
		ELSE
		BEGIN
			INSERT INTO #dbf_systemnet
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@systemnetlist, ',')
		END

		IF OBJECT_ID('tempdb..#dbf_period') IS NOT NULL
			DROP TABLE #dbf_period

		CREATE TABLE #dbf_period
			(
				PR_ID INT NOT NULL
			)

		IF @periodlist IS NULL
		BEGIN
			INSERT INTO #dbf_period
			SELECT PR_ID
			FROM dbo.PeriodTable
			WHERE PR_ACTIVE = 1
		END
		ELSE
		BEGIN
			INSERT INTO #dbf_period
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@periodlist, ',')
		END

		DECLARE @sql VARCHAR(MAX)

		SET @sql = 'SELECT A.PR_DATE AS [Дата],'

		SELECT @sql = @sql + 'SHPVT.[' + CONVERT(VARCHAR, SH_ID) + '] AS ''' + SH_SHORT_NAME + ''','
		FROM
			dbo.SubhostTable INNER JOIN
			#dbf_subhost ON SH_ID = TSH_ID
		ORDER BY SH_ORDER

		SELECT @sql = @sql + 'SSPVT.[' + CONVERT(VARCHAR, SYS_ID) + '] AS ''' + SYS_SHORT_NAME + ''','
		FROM
			dbo.SystemTable INNER JOIN
			#dbf_system ON SYS_ID = TSYS_ID
		ORDER BY SYS_ORDER

		IF @selecttotal = 1
			SET @sql = @sql + '
				(
					SELECT COUNT(*)
					FROM dbo.PeriodRegNewTable b INNER JOIN
						#dbf_system d ON d.TSYS_ID = b.RNN_ID_SYSTEM INNER JOIN
						#dbf_systemtype e ON e.TST_ID = b.RNN_ID_TYPE INNER JOIN
						#dbf_subhost c ON c.TSH_ID = b.RNN_ID_HOST INNER JOIN
						dbo.SystemNetCountTable f ON f.SNC_ID = b.RNN_ID_NET INNER JOIN
						#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
						#dbf_period y ON b.RNN_ID_PERIOD = y.PR_ID
					WHERE a.PR_ID = b.RNN_ID_PERIOD
						AND NOT EXISTS
							(
								SELECT *
								FROM dbo.DistrExchange
								WHERE NEW_HOST = HST_ID
									AND NEW_NUM = RNN_DISTR_NUM
									AND NEW_COMP = RNN_COMP_NUM
							)
				) AS [Итого],'

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + ' FROM 
			(
				SELECT RNN_ID, RNN_ID_HOST, RNN_ID_PERIOD, PR_DATE
				FROM 
					dbo.PeriodRegNewTable b INNER JOIN
					dbo.PeriodTable z ON PR_ID = RNN_ID_PERIOD INNER JOIN
					#dbf_system d ON d.TSYS_ID = b.RNN_ID_SYSTEM INNER JOIN
					#dbf_systemtype e ON e.TST_ID = b.RNN_ID_TYPE INNER JOIN
					dbo.SystemNetCountTable f ON f.SNC_ID = b.RNN_ID_NET INNER JOIN
					#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
					#dbf_period y ON z.PR_ID = y.PR_ID
				WHERE NOT EXISTS
						(
							SELECT *
							FROM dbo.DistrExchange
							WHERE NEW_HOST = HST_ID
								AND NEW_NUM = RNN_DISTR_NUM
								AND NEW_COMP = RNN_COMP_NUM
						)
			) SH
			PIVOT
			(
				COUNT (RNN_ID)
				FOR RNN_ID_HOST IN
					( '

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, SH_ID) + '],'
		FROM
			dbo.SubhostTable INNER JOIN
			#dbf_subhost ON SH_ID = TSH_ID
		ORDER BY SH_ORDER

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + '
					)
			) AS SHPVT
		INNER JOIN
			(
				SELECT RNN_ID, RNN_ID_SYSTEM, RNN_ID_PERIOD, PR_DATE
				FROM 
					dbo.PeriodRegNewTable b INNER JOIN
					dbo.PeriodTable z ON PR_ID = RNN_ID_PERIOD INNER JOIN
					#dbf_systemtype c ON c.TST_ID = b.RNN_ID_TYPE INNER JOIN
					#dbf_system d ON d.TSYS_ID = b.RNN_ID_SYSTEM INNER JOIN
					#dbf_subhost e ON e.TSH_ID = b.RNN_ID_HOST INNER JOIN
					dbo.SystemNetCountTable f ON f.SNC_ID = b.RNN_ID_NET INNER JOIN
					#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
					#dbf_period y ON z.PR_ID = y.PR_ID
				WHERE NOT EXISTS
						(
							SELECT *
							FROM dbo.DistrExchange
							WHERE NEW_HOST = HST_ID
								AND NEW_NUM = RNN_DISTR_NUM
								AND NEW_COMP = RNN_COMP_NUM
						)
			) SS
			PIVOT
			(
				COUNT (RNN_ID)
				FOR RNN_ID_SYSTEM IN
					( '

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, SYS_ID) + '],'
		FROM
			dbo.SystemTable INNER JOIN
			#dbf_system ON SYS_ID = TSYS_ID
		ORDER BY SYS_ORDER

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + '
					)
			) AS SSPVT
			ON SHPVT.RNN_ID_PERIOD = SSPVT.RNN_ID_PERIOD
			INNER JOIN dbo.PeriodTable A ON A.PR_ID = SHPVT.RNN_ID_PERIOD
			ORDER BY A.PR_DATE'



		SET @sql = REPLACE(@sql, '  ', ' ')

		--SELECT @sql

		EXEC (@sql)

		IF OBJECT_ID('tempdb..#dbf_system') IS NOT NULL
			DROP TABLE #dbf_system
		IF OBJECT_ID('tempdb..#dbf_systemtype') IS NOT NULL
			DROP TABLE #dbf_systemtype
		IF OBJECT_ID('tempdb..#dbf_subhost') IS NOT NULL
			DROP TABLE #dbf_subhost
		IF OBJECT_ID('tempdb..#dbf_systemnet') IS NOT NULL
			DROP TABLE #dbf_systemnet
		IF OBJECT_ID('tempdb..#dbf_period') IS NOT NULL
			DROP TABLE #dbf_period

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_NEW_SYSTEM] TO rl_reg_node_r;
GRANT EXECUTE ON [dbo].[REPORT_NEW_SYSTEM] TO rl_reg_node_report_r;
GO
