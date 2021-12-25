USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_NEW_SYSTEM_WEIGHT]
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

		IF OBJECT_ID('tempdb..#dbf_status') IS NOT NULL
			DROP TABLE #dbf_status

		CREATE TABLE #dbf_status
			(
				STAT_ID INT NOT NULL
			)

		IF OBJECT_ID('tempdb..#dbf_system') IS NOT NULL
			DROP TABLE #dbf_system

		CREATE TABLE #dbf_system
			(
				TSYS_ID INT NOT NULL,
				TSYS_PROBLEM	SMALLINT NOT NULL,
				HST_ID	INT
			)

		IF @systemlist IS NULL
		BEGIN
			INSERT INTO #dbf_system
				SELECT
					SYS_ID,
					CASE
						WHEN EXISTS
							(
								SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = SYS_ID
							) THEN 1
						WHEN SYS_REG_NAME IN ('BBKZ', 'UMKZ', 'UBKZ') THEN 2
						ELSE 0
					END, SYS_ID_HOST
				FROM dbo.SystemTable
				WHERE SYS_REPORT = 1
		END
		ELSE
		BEGIN
			--парсить строчку и выбирать нужные значения
			INSERT INTO #dbf_system(TSYS_ID, TSYS_PROBLEM, HST_ID)
				SELECT SYS_ID, CASE
						WHEN EXISTS
							(
								SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = Item
							) THEN 1
						WHEN SYS_REG_NAME IN ('BBKZ', 'UMKZ', 'UBKZ') THEN 2
						ELSE 0
					END , SYS_ID_HOST
				FROM dbo.GET_TABLE_FROM_LIST(@systemlist, ',') INNER JOIN dbo.SystemTable ON SYS_ID = Item
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
			--парсить строчку и выбирать нужные значения
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
			--парсить строчку и выбирать нужные значения
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
			--парсить строчку и выбирать нужные значения
			INSERT INTO #dbf_systemnet
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@systemnetlist, ',')
		END

		IF OBJECT_ID('tempdb..#dbf_period') IS NOT NULL
			DROP TABLE #dbf_period

		CREATE TABLE #dbf_period
			(
				TPR_ID INT NOT NULL
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

	  --Шаг 1. Создать таблицу со всеми полями (надо чтобы были отсортированы по порядку)

		IF OBJECT_ID('tempdb..#stats') IS NOT NULL
			DROP TABLE #stats

		CREATE TABLE #stats
			(
				PR_ID	SMALLINT,
				SYS_ID	SMALLINT,
				SH_ID	SMALLINT,
				SN_GROUP	VARCHAR(50),
				PROBLEM	BIT,
				CNT		INT
			)

		INSERT INTO #stats
			(
				PR_ID, SYS_ID, SH_ID, SN_GROUP, PROBLEM, CNT
			)
			SELECT RNN_ID_PERIOD, RNN_ID_SYSTEM, RNN_ID_HOST, SN_GROUP, PROBLEM, SUM(CNT)
			FROM
				(
					SELECT
						RNN_ID_PERIOD, RNN_ID_SYSTEM, RNN_ID_HOST, SN_GROUP,
						CONVERT(BIT,
							CASE
								WHEN TSYS_PROBLEM = 1
									AND NOT EXISTS
									(
										SELECT *
										FROM
											dbo.PeriodRegExceptView b
											INNER JOIN dbo.DistrStatusTable ON DS_ID = b.REG_ID_STATUS
											INNER JOIN dbo.SystemProblem ON SP_ID_SYSTEM = a.RNN_ID_SYSTEM AND b.REG_ID_SYSTEM = SP_ID_OUT AND SP_ID_PERIOD = b.REG_ID_PERIOD
										WHERE z.REG_COMPLECT = b.REG_COMPLECT AND a.RNN_ID_PERIOD = b.REG_ID_PERIOD AND DS_REG = 0 AND REG_ID_TYPE <> 6 AND a.RNN_ID_SYSTEM <> b.REG_ID_SYSTEM
									) AND EXISTS
									(
										SELECT *
										FROM dbo.SystemProblem
										WHERE SP_ID_SYSTEM = a.RNN_ID_SYSTEM
											AND SP_ID_PERIOD = a.RNN_ID_PERIOD
									) THEN 1
								WHEN TSYS_PROBLEM = 2
									AND REG_ID_TYPE = 20 THEN 1
								ELSE 0
							END) AS PROBLEM,
						COUNT(*) AS CNT
					FROM
						dbo.PeriodRegNewTable a
						INNER JOIN dbo.PeriodRegExceptView z ON z.REG_ID_SYSTEM = a.RNN_ID_SYSTEM AND z.REG_DISTR_NUM = a.RNN_DISTR_NUM AND z.REG_COMP_NUM = a.RNN_COMP_NUM AND z.REG_ID_PERIOD = a.RNN_ID_PERIOD
						INNER JOIN #dbf_period ON TPR_ID = RNN_ID_PERIOD
						INNER JOIN #dbf_system ON TSYS_ID = RNN_ID_SYSTEM
						INNER JOIN dbo.SystemNetCountTable ON SNC_ID = RNN_ID_NET
						INNER JOIN #dbf_systemnet ON TSN_ID = SNC_ID_SN
						INNER JOIN #dbf_subhost ON TSH_ID = RNN_ID_HOST
						INNER JOIN #dbf_systemtype ON TST_ID = RNN_ID_TYPE
						INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
					WHERE NOT EXISTS
							(
								SELECT *
								FROM dbo.DistrExchange
								WHERE NEW_HOST = HST_ID
									AND NEW_NUM = REG_DISTR_NUM
									AND NEW_COMP = REG_COMP_NUM
							)
					GROUP BY RNN_ID_PERIOD, RNN_ID_SYSTEM, RNN_ID_HOST, SN_GROUP, REG_COMPLECT, REG_ID_TYPE, TSYS_PROBLEM
				) AS o_O
			GROUP BY RNN_ID_PERIOD, RNN_ID_SYSTEM, RNN_ID_HOST, SN_GROUP, PROBLEM

		CREATE UNIQUE CLUSTERED INDEX IX_STATS ON #stats(PR_ID, SYS_ID, SH_ID, SN_GROUP, PROBLEM)

		DECLARE @sql VARCHAR(MAX)

		IF OBJECT_ID('tempdb..#keys') IS NOT NULL
			DROP TABLE #keys

		CREATE TABLE #keys
			(
				KEY_ID INT IDENTITY(1, 1) PRIMARY KEY,
				KEY_NAME NVARCHAR(64),
				KEY_HOST INT,
				KEY_SYS INT,
				KEY_NET VARCHAR(50),
				KEY_PROBLEM	BIT,
				SN_ORDER	SMALLINT,
				SYS_ORDER	SMALLINT,
				SH_ORDER	SMALLINT
			)

		IF @selecttotal = 1
		BEGIN
			IF OBJECT_ID('tempdb..#ric') IS NOT NULL
				DROP TABLE #ric

			CREATE TABLE #ric
				(
					KEY_ID INT IDENTITY(1, 1) PRIMARY KEY,
					KEY_NAME NVARCHAR(64),
					KEY_HOST INT,
					KEY_SYS INT,
					KEY_NET VARCHAR(50),
					KEY_PROBLEM	BIT,
					SN_ORDER	SMALLINT,
					SYS_ORDER	SMALLINT
				)

			INSERT INTO #ric
				SELECT DISTINCT
						'РИЦ | ' + SYS_SHORT_NAME +
						CASE TSYS_PROBLEM_TYPE
							WHEN 0 THEN ''
							WHEN 2 THEN
								CASE TSYS_PROBLEM
									WHEN 0 THEN ' | ДД2'
									WHEN 2 THEN ' | ДЗ2/ДЗ3'
								END
							WHEN 1 THEN
								CASE TSYS_PROBLEM
									WHEN 1 THEN ' Проблемный'
									ELSE ''
								END
							ELSE ' ???'
						END + ' | ' + SN_GROUP, 0, SYS_ID, SN_GROUP, TSYS_PROBLEM, MIN(SN_ORDER) AS SN_ORD, SYS_ORDER
				FROM
					dbo.SystemNetTable a
					INNER JOIN #dbf_systemnet c ON c.TSN_ID = a.SN_ID,
					dbo.SystemTable b
					INNER JOIN
						(
							SELECT TSYS_ID, 0 AS TSYS_PROBLEM, TSYS_PROBLEM AS TSYS_PROBLEM_TYPE
							FROM #dbf_system

							UNION ALL

							SELECT TSYS_ID, 1 AS TSYS_PROBLEM, TSYS_PROBLEM AS TSYS_PROBLEM_TYPE
							FROM #dbf_system
							WHERE TSYS_PROBLEM = 1

							UNION ALL

							SELECT TSYS_ID, 2 AS TSYS_PROBLEM, TSYS_PROBLEM AS TSYS_PROBLEM_TYPE
							FROM #dbf_system
							WHERE TSYS_PROBLEM = 2
						) d ON d.TSYS_ID = b.SYS_ID
				GROUP BY SYS_SHORT_NAME, TSYS_PROBLEM, SN_GROUP, SYS_ID, SN_GROUP, TSYS_PROBLEM, SYS_ORDER, TSYS_PROBLEM_TYPE
				ORDER BY SYS_ORDER, TSYS_PROBLEM, SN_ORD
		END


		INSERT INTO #keys
			SELECT DISTINCT
				SH_SHORT_NAME + ' | ' +
				SYS_SHORT_NAME +
				CASE TSYS_PROBLEM_TYPE
							WHEN 0 THEN ''
							WHEN 2 THEN
								CASE TSYS_PROBLEM
									WHEN 0 THEN ' | ДД2'
									WHEN 2 THEN ' | ДЗ2/ДЗ3'
								END
							WHEN 1 THEN
								CASE TSYS_PROBLEM
									WHEN 1 THEN ' Проблемный'
									ELSE ''
								END
							ELSE ' ???'
				END + ' | ' + SN_GROUP, SH_ID, SYS_ID, SN_GROUP, TSYS_PROBLEM, MIN(SN_ORDER) AS SN_ORD, SYS_ORDER, SH_ORDER
			FROM
				dbo.SystemNetTable a
				INNER JOIN #dbf_systemnet d ON d.TSN_ID = a.SN_ID,
				dbo.SystemTable b
				INNER JOIN
					(
						SELECT TSYS_ID, 0 AS TSYS_PROBLEM, TSYS_PROBLEM AS TSYS_PROBLEM_TYPE
						FROM #dbf_system

						UNION ALL

						SELECT TSYS_ID, 1 AS TSYS_PROBLEM, TSYS_PROBLEM AS TSYS_PROBLEM_TYPE
						FROM #dbf_system
						WHERE TSYS_PROBLEM = 1

						UNION ALL

						SELECT TSYS_ID, 2 AS TSYS_PROBLEM, TSYS_PROBLEM AS TSYS_PROBLEM_TYPE
						FROM #dbf_system
						WHERE TSYS_PROBLEM = 2
					) e ON e.TSYS_ID = b.SYS_ID,
				dbo.SubhostTable c
				INNER JOIN #dbf_subhost f ON f.TSH_ID = c.SH_ID
			GROUP BY SH_SHORT_NAME, SYS_SHORT_NAME, TSYS_PROBLEM, SN_GROUP, SH_ID, SYS_ID, SN_GROUP, TSYS_PROBLEM, SYS_ORDER, SH_ORDER, TSYS_PROBLEM_TYPE
			ORDER BY SH_ORDER, SYS_ORDER, TSYS_PROBLEM, SN_ORD


		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				[Номер строки] INT IDENTITY(1,1),
				[Дата] SMALLDATETIME
			)

		IF @selecttotal = 1
		BEGIN
			SET @sql = 'ALTER TABLE #result ADD'
			SELECT @sql = @sql + ' [' + KEY_NAME + '] INT,'
			FROM #ric
			ORDER BY KEY_ID

			SET @sql = LEFT(@sql, LEN(@sql) - 1)

			EXEC (@sql)
		END

		SET @sql = 'ALTER TABLE #result ADD'
		SELECT @sql = @sql + ' [' + KEY_NAME + '] INT,'
		FROM #keys
		ORDER BY KEY_ID

		SET @sql = LEFT(@sql, LEN(@sql) - 1)
		EXEC (@sql)



		SET @sql = '
		INSERT INTO #result
		SELECT KPVT.PR_DATE,'

		IF @selecttotal = 1
			SELECT @sql = @sql +
				' ISNULL(RPVT.[' + CONVERT(VARCHAR, KEY_ID)  + '], 0),'
			FROM #ric
			ORDER BY KEY_ID

		SELECT @sql = @sql + ' ISNULL(KPVT.[' + CONVERT(VARCHAR, KEY_ID)  + '], 0),'
		FROM #keys
		ORDER BY KEY_ID

		-- производится выборка по всем фильтрам без разбиения по подхостам, типам сети и системам

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql +
			'
				FROM
					(
						SELECT a.PR_ID, KEY_ID, PR_DATE, CNT
						FROM
							#stats a
							INNER JOIN dbo.PeriodTable b ON a.PR_ID = b.PR_ID
							INNER JOIN #keys ON KEY_HOST = SH_ID
									AND KEY_SYS = SYS_ID
									AND KEY_NET = SN_GROUP
									AND KEY_PROBLEM = PROBLEM
					) KEYS PIVOT
					(
						SUM(CNT)
						FOR KEY_ID IN
							(
						'

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_ID) + '],'
		FROM #keys
		ORDER BY KEY_ID

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql +
						'	)
			) AS KPVT '

		IF @selecttotal = 1
		BEGIN
			SET @sql = @sql +
			' INNER JOIN
			(
				SELECT a.PR_ID, KEY_ID, PR_DATE, CNT
				FROM
					#stats a
					INNER JOIN dbo.PeriodTable b ON a.PR_ID = b.PR_ID
					INNER JOIN #ric ON KEY_SYS = SYS_ID
							AND KEY_NET = SN_GROUP
							AND KEY_PROBLEM = PROBLEM
			) RIC
			PIVOT
			(
				SUM(CNT)
				FOR KEY_ID IN
					(	'

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_ID) + '],'
		FROM #ric
		ORDER BY KEY_ID

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql +
					')
			) AS RPVT ON RPVT.PR_ID = KPVT.PR_ID '
		END

		SET @sql = @sql + ' ORDER BY KPVT.PR_DATE'


		--PRINT @SQL
		EXEC (@sql)


		IF @selecttotal = 1
			ALTER TABLE #result ADD
				[Итого] INT,
				[Вес] DECIMAL(10, 4)

		/*
			А вот тут надо просуммировать все поля и посчитать веса
		*/

		SET @sql = 'UPDATE #result SET [Итого] = '
		SELECT @sql = @sql  + '[' + KEY_NAME + ']+'
		FROM #keys

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		EXEC (@sql)

		IF @selecttotal = 1
		BEGIN
			SET @sql = 'UPDATE #result SET [Вес] = '

			SELECT @sql = @sql + 'CONVERT(DECIMAL(8, 4), [' + KEY_NAME + ']) * dbo.GetWeightProblem(' + CONVERT(VARCHAR(20), KEY_SYS) + ', ''' + KEY_NET + ''', [Дата], ' + CONVERT(VARCHAR(20), KEY_PROBLEM) + ') + '
			FROM #ric

			SET @sql = LEFT(@sql, LEN(@sql) - 1)

			EXEC (@sql)

			PRINT @sql

			/*
			SET @sql = 'UPDATE a SET [Период П4|Вес на начало] = Ric.VKSPGet(' + CONVERT(VARCHAR(20), @PR_ALG)

			SELECT @sql = @sql + 'CONVERT(DECIMAL(8, 4), b.[' + KEY_NAME + ']) * dbo.GetWeightProblem(' + CONVERT(VARCHAR(20), KEY_SYS) + ', ' + CONVERT(VARCHAR(20), KEY_NET) + ', a.[Дата], ' + CONVERT(VARCHAR(20), KEY_PROBLEM) + ') + '
			FROM #ric

			SET @sql = LEFT(@sql, LEN(@sql) - 1)

			SET @sql = @sql + 'FROM #result a INNER JOIN #result b ON a.[Дата] = DATEADD(MONTH, 12, b.[Дата])'

			EXEC (@sql)

			UPDATE #result SET [Период П4|Прирост веса] = [Вес] - [Период П4|Вес на начало]

			UPDATE #result SET [Период П4|Прирост веса %] = 100 * [Период П4|Прирост веса] / [Период П4|Вес на начало]
			*/
		END


		SELECT *
		FROM #result

		--SELECT * FROM #keys

		IF OBJECT_ID('tempdb..#dbf_status') IS NOT NULL
			DROP TABLE #dbf_status
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
		IF OBJECT_ID('tempdb..#keys') IS NOT NULL
			DROP TABLE #keys
		IF OBJECT_ID('tempdb..#ric') IS NOT NULL
			DROP TABLE #ric
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result
		IF OBJECT_ID('tempdb..#stats') IS NOT NULL
			DROP TABLE #stats

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_NEW_SYSTEM_WEIGHT] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_NEW_SYSTEM_WEIGHT] TO rl_reg_report_r;
GO
