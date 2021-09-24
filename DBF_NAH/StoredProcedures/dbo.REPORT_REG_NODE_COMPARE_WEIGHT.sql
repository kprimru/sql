USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[REPORT_REG_NODE_COMPARE_WEIGHT]
	@SRC_PR		SMALLINT,
	@DEST_PR	SMALLINT,
	@NEW		BIT,
	@LOST		BIT,
	@CONNECT	BIT,
	@DISCONNECT	BIT,
	@NET		BIT,
	@SYS		BIT,
	@SUBHOST	BIT,
	@HOST		BIT,
	@SYS_LIST	VARCHAR(MAX),
	@SH_LIST	VARCHAR(MAX),
	@SST_LIST	VARCHAR(MAX),
	@NEW_WEIGHT	BIT = 0,
	@TITLE		VarChar(256) = NULL OUTPUT
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

		SELECT @TITLE = 'Сравнение РЦ в период от ' + Convert(VarChar(20), S.PR_EREPORT, 104) + ' по ' + Convert(VarChar(20), D.PR_EREPORT, 104)
		FROM dbo.PeriodTable S
		CROSS JOIN dbo.PeriodTable D
		WHERE S.PR_ID = @SRC_PR
			AND D.PR_ID = @DEST_PR;

		/******************************************************
		Строим таблицы фильтров по системам, подхостам
		и типам сети
		*******************************************************/

		IF OBJECT_ID('tempdb..#system') IS NOT NULL
			DROP TABLE #system

		CREATE TABLE #system
			(
				TSYS_ID	SMALLINT PRIMARY KEY,
				SYS_ID_HOST	SMALLINT,
				SYS_PROBLEM SMALLINT,
				SYS_FILTER	BIT
			)

		IF @SYS_LIST IS NULL
			INSERT INTO #system(TSYS_ID, SYS_ID_HOST, SYS_PROBLEM, SYS_FILTER)
				SELECT
					SYS_ID, SYS_ID_HOST,
					CASE
						WHEN EXISTS
							(
								SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = SYS_ID
							) THEN 1
						WHEN SYS_REG_NAME IN ('BBKZ', 'UMKZ', 'UBKZ', 'SPK-I', 'SPK-II', 'SPK-III', 'SPK-IV', 'SPK-V') THEN 2
						ELSE 0
					END AS SYS_PROBLEM,
					1
				FROM dbo.SystemTable
		ELSE
			INSERT INTO #system(TSYS_ID, SYS_ID_HOST, SYS_PROBLEM, SYS_FILTER)
				SELECT
					SYS_ID, SYS_ID_HOST,
					CASE
						WHEN EXISTS
							(
								SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = SYS_ID
							) THEN 1
						WHEN SYS_REG_NAME IN ('BBKZ', 'UMKZ', 'UBKZ', 'SPK-I', 'SPK-II', 'SPK-III', 'SPK-IV', 'SPK-V') THEN 2
						ELSE 0
					END AS SYS_PROBLEM,
					CASE
						WHEN Item IS NULL THEN 0
						ELSE 1
					END AS SYS_FILTER
				FROM
					dbo.SystemTable
					INNER JOIN dbo.GET_TABLE_FROM_LIST(@SYS_LIST, ',') ON SYS_ID = Item

		IF OBJECT_ID('tempdb..#subhost') IS NOT NULL
			DROP TABLE #subhost

		CREATE TABLE #subhost
			(
				TSH_ID SMALLINT PRIMARY KEY
			)

		IF @SH_LIST IS NULL
			INSERT INTO #subhost(TSH_ID)
				SELECT SH_ID FROM dbo.SubhostTable WHERE SH_ACTIVE = 1
		ELSE
			INSERT INTO #subhost
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@SH_LIST, ',')

		IF OBJECT_ID('tempdb..#system_type') IS NOT NULL
			DROP TABLE #system_type

		CREATE TABLE #system_type
			(
				TSST_ID INT PRIMARY KEY
			)

		IF @SST_LIST IS NULL
			INSERT INTO #system_type(TSST_ID)
				SELECT SST_ID FROM dbo.SystemTypeTable WHERE SST_ACTIVE = 1
		ELSE
			INSERT INTO #system_type
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@SST_LIST, ',')

		DECLARE @SQL VARCHAR(MAX)

		IF OBJECT_ID('tempdb..#source') IS NOT NULL
			DROP TABLE #source

		CREATE TABLE #source
			(
				SYS_ID_HOST			SMALLINT,
				REG_ID_SYSTEM		SMALLINT,
				REG_DISTR_NUM		INT,
				REG_COMP_NUM		TINYINT,
				REG_ID_HOST			SMALLINT,
				REG_ID_TYPE			SMALLINT,
				REG_ID_NET			SMALLINT,
				REG_ID_STATUS		SMALLINT,
				REG_COMPLECT		VARCHAR(50),
				REG_COMMENT			VARCHAR(100),
				REG_PROBLEM			BIT,
				REG_UPDATE			BIT,
				REG_WEIGHT			DECIMAL(10, 4)
			)

		/******************************************************
		Заполняем исходный список (системы-сеть-подхост и т.д.)
		*******************************************************/

		INSERT INTO #source(
				SYS_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM, REG_ID_HOST, REG_ID_TYPE,
				REG_ID_NET, REG_ID_STATUS, REG_COMPLECT, REG_COMMENT, REG_PROBLEM)
			SELECT
				SYS_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM, REG_ID_HOST, REG_ID_TYPE,
				REG_ID_NET, REG_ID_STATUS, REG_COMPLECT, REG_COMMENT, 0
			FROM
				dbo.PeriodRegExceptView
				INNER JOIN dbo.SystemTable ON SYS_ID = REG_ID_SYSTEM
			WHERE REG_ID_PERIOD = @SRC_PR

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #source (SYS_ID_HOST, REG_DISTR_NUM, REG_COMP_NUM)'
		EXEC (@SQL)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #source (REG_COMPLECT) INCLUDE (REG_ID_SYSTEM, REG_ID_STATUS, REG_ID_TYPE)'
		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#dest') IS NOT NULL
			DROP TABLE #dest

		CREATE TABLE #dest
			(
				SYS_ID_HOST			SMALLINT,
				REG_ID_SYSTEM		SMALLINT,
				REG_DISTR_NUM		INT,
				REG_COMP_NUM		TINYINT,
				REG_ID_HOST			SMALLINT,
				REG_ID_TYPE			SMALLINT,
				REG_ID_NET			SMALLINT,
				REG_ID_STATUS		SMALLINT,
				REG_COMPLECT		VARCHAR(50),
				REG_COMMENT			VARCHAR(100),
				REG_PROBLEM			BIT,
				REG_UPDATE			BIT,
				REG_WEIGHT			DECIMAL(10, 4)
			)

		/******************************************************
		Заполняем целевой список (хосты-системы-сеть и т.д.)
		*******************************************************/

		INSERT INTO #dest(
				SYS_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM, REG_ID_HOST, REG_ID_TYPE,
				REG_ID_NET, REG_ID_STATUS, REG_COMPLECT, REG_COMMENT, REG_PROBLEM)
			SELECT
				SYS_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM, REG_ID_HOST, REG_ID_TYPE,
				REG_ID_NET, REG_ID_STATUS, REG_COMPLECT, REG_COMMENT, 0
			FROM
				dbo.PeriodRegExceptView
				INNER JOIN dbo.SystemTable ON SYS_ID = REG_ID_SYSTEM
			WHERE REG_ID_PERIOD = @DEST_PR

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #dest (SYS_ID_HOST, REG_DISTR_NUM, REG_COMP_NUM)'
		EXEC (@SQL)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #dest (REG_COMPLECT) INCLUDE (REG_ID_SYSTEM, REG_ID_STATUS, REG_ID_TYPE)'
		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#problem') IS NOT NULL
			DROP TABLE #problem

		CREATE TABLE #problem
			(
				SYS_ID	SMALLINT PRIMARY KEY,
				SYS_ID_HOST	SMALLINT
			)

		/******************************************************
		Устанавливаем признак для проблемных РЗ
		*******************************************************/

		INSERT INTO #problem(SYS_ID, SYS_ID_HOST)
			SELECT SYS_ID, SYS_ID_HOST
			FROM dbo.SystemTable
			WHERE EXISTS
				(
					SELECT *
					FROM dbo.SystemProblem
					WHERE SP_ID_SYSTEM = SYS_ID
						AND SP_ID_PERIOD = @SRC_PR
				)

		UPDATE a
		SET REG_PROBLEM = CONVERT(BIT,
							CASE
								WHEN SYS_PROBLEM = 1
									AND NOT EXISTS
									(
										SELECT *
										FROM
											#source b
											INNER JOIN dbo.DistrStatusTable ON DS_ID = b.REG_ID_STATUS
											INNER JOIN dbo.SystemProblem ON SP_ID_SYSTEM = a.REG_ID_SYSTEM
																		AND b.REG_ID_SYSTEM = SP_ID_OUT
																		AND SP_ID_PERIOD = @SRC_PR
										WHERE a.REG_COMPLECT = b.REG_COMPLECT 
											AND DS_REG = 0 AND REG_ID_TYPE <> 6
											AND a.REG_ID_SYSTEM <> b.REG_ID_SYSTEM
									) THEN 1
								WHEN SYS_PROBLEM = 2
									AND REG_ID_TYPE IN (20, 22) THEN 1
								ELSE 0
							END)
		FROM
			#source a
			--INNER JOIN #problem ON REG_ID_SYSTEM = SYS_ID
			INNER JOIN #system ON a.REG_ID_SYSTEM = TSYS_ID

		UPDATE a
		SET REG_PROBLEM = CONVERT(BIT,
							CASE
								WHEN SYS_PROBLEM = 1
									AND NOT EXISTS
									(
										SELECT *
										FROM
											#dest b
											INNER JOIN dbo.DistrStatusTable ON DS_ID = b.REG_ID_STATUS
											INNER JOIN dbo.SystemProblem ON SP_ID_SYSTEM = a.REG_ID_SYSTEM
																		AND b.REG_ID_SYSTEM = SP_ID_OUT
																		AND SP_ID_PERIOD = @DEST_PR
										WHERE a.REG_COMPLECT = b.REG_COMPLECT 
											AND DS_REG = 0 AND REG_ID_TYPE <> 6
											AND a.REG_ID_SYSTEM <> b.REG_ID_SYSTEM
									) THEN 1
								WHEN SYS_PROBLEM = 2
									AND REG_ID_TYPE IN (20, 22) THEN 1
								ELSE 0
							END)
		FROM
			#dest a
			--INNER JOIN #problem ON REG_ID_SYSTEM = SYS_ID
			INNER JOIN #system ON a.REG_ID_SYSTEM = TSYS_ID

		/******************************************************
		Вычисляем начальный вес для каждой позиции исходного списка
		*******************************************************/

		IF @NEW_WEIGHT = 0
		BEGIN
			UPDATE a
			SET REG_WEIGHT = SW_WEIGHT * SNCC_WEIGHT * CASE DS_REG WHEN 0 THEN 1 ELSE 0 END
			FROM
				#source a
				INNER JOIN dbo.SystemTypeTable b ON a.REG_ID_TYPE = b.SST_ID
				INNER JOIN dbo.SystemWeightTable ON SW_ID_PERIOD = @SRC_PR AND SW_ID_SYSTEM = REG_ID_SYSTEM AND SW_PROBLEM = REG_PROBLEM
				INNER JOIN dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
				INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
				INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = @SRC_PR
				INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			WHERE SST_ID_SUB = 4
		END
		ELSE
		BEGIN
			UPDATE a
			SET REG_WEIGHT = WEIGHT * CASE DS_REG WHEN 0 THEN 1 ELSE 0 END
			FROM #source a
			INNER JOIN dbo.WeightRules ON REG_ID_TYPE = ID_TYPE
										AND REG_ID_SYSTEM = ID_SYSTEM
										AND REG_ID_NET = ID_NET
			INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			WHERE ID_PERIOD = @SRC_PR
		END

		/******************************************************
		Заполняем вес для каждой позиции целевого списка
		*******************************************************/

		IF @NEW_WEIGHT = 0
		BEGIN
			UPDATE a
			SET REG_WEIGHT = SW_WEIGHT * SNCC_WEIGHT * CASE DS_REG WHEN 0 THEN 1 ELSE 0 END
			FROM
				#dest a
				INNER JOIN dbo.SystemTypeTable b ON a.REG_ID_TYPE = b.SST_ID
				INNER JOIN dbo.SystemWeightTable ON SW_ID_PERIOD = @DEST_PR AND SW_ID_SYSTEM = REG_ID_SYSTEM AND SW_PROBLEM = REG_PROBLEM
				INNER JOIN dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
				INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
				INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = @DEST_PR
				INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			WHERE SST_ID_SUB = 4
		END
		ELSE
		BEGIN
			UPDATE a
			SET REG_WEIGHT = WEIGHT * CASE DS_REG WHEN 0 THEN 1 ELSE 0 END
			FROM #dest a
			INNER JOIN dbo.WeightRules ON REG_ID_TYPE = ID_TYPE
										AND REG_ID_SYSTEM = ID_SYSTEM
										AND REG_ID_NET = ID_NET
			INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			WHERE ID_PERIOD = @DEST_PR
		END

		IF OBJECT_ID('tempdb..#hosts') IS NOT NULL
			DROP TABLE #hosts

		CREATE TABLE #hosts
			(
				HST_ID	SMALLINT,
				DISTR	INT,
				COMP	TINYINT
			)

		/******************************************************
		Строим список дистрибутивов, которые поменялись
		*******************************************************/

		INSERT INTO #hosts(HST_ID, DISTR, COMP)
			SELECT SRC.SYS_ID_HOST, SRC.REG_DISTR_NUM, SRC.REG_COMP_NUM
			FROM
				(
					SELECT
						SYS_ID_HOST, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_SYSTEM, REG_ID_HOST, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS,
						REG_PROBLEM, REG_WEIGHT
					FROM #source
				) AS SRC
				INNER JOIN
				(
					SELECT
						SYS_ID_HOST, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_SYSTEM, REG_ID_HOST, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS,
						REG_PROBLEM, REG_WEIGHT
					FROM #dest
				) AS DST ON SRC.SYS_ID_HOST = DST.SYS_ID_HOST
					AND SRC.REG_DISTR_NUM = DST.REG_DISTR_NUM
					AND SRC.REG_COMP_NUM = DST.REG_COMP_NUM
			WHERE SRC.REG_ID_SYSTEM <> DST.REG_ID_SYSTEM
				OR
				SRC.REG_ID_NET <> DST.REG_ID_NET
				OR
				SRC.REG_ID_HOST <> DST.REG_ID_HOST
				OR
				SRC.REG_ID_TYPE <> DST.REG_ID_TYPE
				OR
				SRC.REG_ID_STATUS <> DST.REG_ID_STATUS
				OR
				SRC.REG_PROBLEM <> DST.REG_PROBLEM
				OR
				SRC.REG_WEIGHT <> DST.REG_WEIGHT

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #hosts (DISTR, HST_ID, COMP)'
		EXEC (@SQL)

		--SELECT * FROM #hosts
		UPDATE a
		SET REG_UPDATE = 1
		FROM
			#source a
			INNER JOIN #hosts ON HST_ID = SYS_ID_HOST
					AND DISTR = REG_DISTR_NUM
					AND COMP = REG_COMP_NUM

		UPDATE a
		SET REG_UPDATE = 1
		FROM
			#dest a
			INNER JOIN #hosts ON HST_ID = SYS_ID_HOST
					AND DISTR = REG_DISTR_NUM
					AND COMP = REG_COMP_NUM



		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #source (REG_UPDATE) INCLUDE (SYS_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM, REG_ID_HOST, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS, REG_COMMENT, REG_PROBLEM)'
		EXEC (@SQL)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #dest (REG_UPDATE) INCLUDE (SYS_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM, REG_ID_HOST, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS, REG_COMMENT, REG_PROBLEM)'
		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#rn') IS NOT NULL
			DROP TABLE #rn

		CREATE TABLE #rn
			(
				ID INT IDENTITY(1, 1) PRIMARY KEY,
				REG_ID_HST SMALLINT,
				REG_ID_SYSTEM SMALLINT,
				REG_DISTR_NUM INT,
				REG_COMP_NUM TINYINT,
				REG_ID_NET SMALLINT,
				REG_ID_HOST SMALLINT,
				REG_TP VARCHAR(50),
				REG_NOTE VARCHAR(500),
				REG_COMMENT VARCHAR(500),
				REG_ID_TYPE SMALLINT,
				REG_PROBLEM	BIT,
				REG_WEIGHT	DECIMAL(10, 4)
			)

		--1. Новые системы

		/******************************************************
		Заполняем список новых систем
		*******************************************************/


		IF @NEW = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, SYS_ID, REG_DISTR_NUM, REG_COMP_NUM,
					REG_ID_NET, REG_ID_HOST, 'Новая система', '', REG_COMMENT,
					REG_ID_TYPE, a.REG_PROBLEM, a.REG_WEIGHT
				FROM
					#dest a
					INNER JOIN dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID
					INNER JOIN #system ON TSYS_ID = SYS_ID
					INNER JOIN #subhost ON TSH_ID = REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = REG_ID_TYPE
				WHERE SYS_FILTER = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM
								#source z
							WHERE z.REG_DISTR_NUM = a.REG_DISTR_NUM
								AND z.REG_COMP_NUM = a.REG_COMP_NUM
								AND b.SYS_ID_HOST = z.SYS_ID_HOST
						)
					AND NOT EXISTS
						(
							SELECT *
							FROM
								#source z
								INNER JOIN dbo.DistrExchange y ON z.REG_DISTR_NUM = y.OLD_NUM
															AND z.REG_COMP_NUM = y.OLD_COMP
															AND z.SYS_ID_HOST = y.OLD_HOST
							WHERE NEW_NUM = a.REG_DISTR_NUM
								AND NEW_COMP = a.REG_COMP_NUM
								AND NEW_HOST = a.SYS_ID_HOST
						)



		--2. Исчезнувшие системы
		/******************************************************
		Заполняем список систем, ушедших в теневой список
		*******************************************************/
		IF @LOST = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					REG_ID_HOST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
					REG_ID_NET, REG_ID_HOST, 'Система пропала', '', REG_COMMENT,
					REG_ID_TYPE, REG_PROBLEM, -a.REG_WEIGHT
				FROM
					#source a INNER JOIN
					#system ON REG_ID_SYSTEM = TSYS_ID INNER JOIN
					#subhost ON TSH_ID = REG_ID_HOST INNER JOIN
					#system_type ON TSST_ID = REG_ID_TYPE
				WHERE SYS_FILTER = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM
								#dest z
							WHERE z.REG_DISTR_NUM = a.REG_DISTR_NUM
								AND z.REG_COMP_NUM = a.REG_COMP_NUM
								AND a.SYS_ID_HOST = z.SYS_ID_HOST

						)
					AND NOT EXISTS
						(
							SELECT *
							FROM
								#dest z
								INNER JOIN dbo.DistrExchange y ON z.REG_DISTR_NUM = y.NEW_NUM
															AND z.REG_COMP_NUM = y.NEW_COMP
															AND z.SYS_ID_HOST = y.NEW_HOST
							WHERE OLD_NUM = a.REG_DISTR_NUM
								AND OLD_COMP = a.REG_COMP_NUM
								AND OLD_HOST = a.SYS_ID_HOST
						)


		--3. Изменение системы
		/******************************************************
		Заполняем список замен систем в пределах одного хоста
		*******************************************************/
		IF @sys = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, e.SYS_ID, d.REG_DISTR_NUM, d.REG_COMP_NUM,
					d.REG_ID_NET, d.REG_ID_HOST, 'Изменилась система',
					'Была "' + b.SYS_SHORT_NAME + CASE a.REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END + '", ' +
					'стала "' + e.SYS_SHORT_NAME + CASE d.REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END + '"',
					d.REG_COMMENT, d.REG_ID_TYPE, d.REG_PROBLEM, ISNULL(d.REG_WEIGHT, 0) - ISNULL(a.REG_WEIGHT, 0)
				FROM
					#source a
					INNER JOIN dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID
					INNER JOIN #dest d ON d.REG_DISTR_NUM = a.REG_DISTR_NUM
									AND d.REG_COMP_NUM = a.REG_COMP_NUM
									AND d.SYS_ID_HOST = a.SYS_ID_HOST
					INNER JOIN dbo.SystemTable e ON d.REG_ID_SYSTEM = e.SYS_ID
					INNER JOIN #system ON e.SYS_ID = TSYS_ID
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
					INNER JOIN dbo.DistrStatusTable k ON k.DS_ID = d.REG_ID_STATUS
				WHERE SYS_FILTER = 1
					AND a.REG_UPDATE = 1
					AND d.REG_UPDATE = 1
					AND (
							(a.REG_ID_SYSTEM <> d.REG_ID_SYSTEM)
							OR
							(a.REG_PROBLEM <> d.REG_PROBLEM)
						)
					AND k.DS_REG = 0

				UNION ALL

				SELECT
					a.SYS_ID_HOST, e.SYS_ID, d.REG_DISTR_NUM, d.REG_COMP_NUM,
					d.REG_ID_NET, d.REG_ID_HOST, 'Изменилась система',
					'Была "' + b.SYS_SHORT_NAME + CASE a.REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END + '", ' +
					'стала "' + e.SYS_SHORT_NAME + CASE d.REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END + '"',
					d.REG_COMMENT, d.REG_ID_TYPE, d.REG_PROBLEM, ISNULL(d.REG_WEIGHT, 0) - ISNULL(a.REG_WEIGHT, 0)
				FROM
					#source a
					INNER JOIN dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID
					INNER JOIN dbo.DistrExchange c ON c.OLD_NUM = a.REG_DISTR_NUM
												AND c.OLD_COMP = a.REG_COMP_NUM
												AND c.OLD_HOST = a.SYS_ID_HOST
					INNER JOIN #dest d ON d.REG_DISTR_NUM = c.NEW_NUM
									AND d.REG_COMP_NUM = c.NEW_COMP
									AND d.SYS_ID_HOST = c.NEW_HOST
					INNER JOIN dbo.SystemTable e ON d.REG_ID_SYSTEM = e.SYS_ID
					INNER JOIN #system ON e.SYS_ID = TSYS_ID
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
					INNER JOIN dbo.DistrStatusTable k ON k.DS_ID = d.REG_ID_STATUS
				WHERE SYS_FILTER = 1
					--AND a.REG_UPDATE = 1
					--AND d.REG_UPDATE = 1
					AND (
							(a.REG_ID_SYSTEM <> d.REG_ID_SYSTEM)
							OR
							(a.REG_PROBLEM <> d.REG_PROBLEM)
						)
					AND NOT (b.SYS_REG_NAME = 'BUH' AND e.SYS_REG_NAME = 'BUHL')
					AND NOT (b.SYS_REG_NAME = 'BUHU' AND e.SYS_REG_NAME = 'BUHUL')
					AND k.DS_REG = 0
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #source q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)

				UNION ALL

				SELECT
					a.SYS_ID_HOST, e.SYS_ID, d.REG_DISTR_NUM, d.REG_COMP_NUM,
					d.REG_ID_NET, d.REG_ID_HOST, 'Изменился вес',
					''/*'Была "' + b.SYS_SHORT_NAME + CASE a.REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END + '", ' +
					'стала "' + e.SYS_SHORT_NAME + CASE d.REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END + '"'*/,
					d.REG_COMMENT, d.REG_ID_TYPE, d.REG_PROBLEM, ISNULL(d.REG_WEIGHT, 0) - ISNULL(a.REG_WEIGHT, 0)
				FROM
					#source a
					INNER JOIN dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID
					INNER JOIN #dest d ON d.REG_DISTR_NUM = a.REG_DISTR_NUM
									AND d.REG_COMP_NUM = a.REG_COMP_NUM
									AND d.SYS_ID_HOST = a.SYS_ID_HOST
					INNER JOIN dbo.SystemTable e ON d.REG_ID_SYSTEM = e.SYS_ID
					INNER JOIN #system ON e.SYS_ID = TSYS_ID
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
					INNER JOIN dbo.DistrStatusTable k ON k.DS_ID = d.REG_ID_STATUS
				WHERE SYS_FILTER = 1
					AND a.REG_UPDATE = 1
					AND d.REG_UPDATE = 1
					AND (
							(a.REG_ID_SYSTEM = d.REG_ID_SYSTEM)
							AND
							(a.REG_PROBLEM = d.REG_PROBLEM)
							AND
							(a.REG_WEIGHT <> d.REG_WEIGHT)
							--AND (a.REG_PROBLEM = 1)
							AND (a.REG_ID_NET = d.REG_ID_NET)
						)
					AND k.DS_REG = 0


		--4. Изменение типа сети
		/******************************************************
		Заполняем список дистрибутивов, у которых поменялась сеть
		*******************************************************/
		IF @net = 1
		BEGIN
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, f.REG_ID_HOST, 'Изменился тип сети',
					'Был "' + e.SN_NAME + '", стал "' + j.SN_NAME + '"', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, f.REG_WEIGHT - a.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.SystemNetCountTable d ON SNC_ID = REG_ID_NET
					INNER JOIN dbo.SystemNetTable e ON SN_ID = SNC_ID_SN
					INNER JOIN #dest f ON f.REG_DISTR_NUM = a.REG_DISTR_NUM
									AND f.REG_COMP_NUM = a.REG_COMP_NUM
									AND f.SYS_ID_HOST = a.SYS_ID_HOST
					INNER JOIN dbo.SystemNetCountTable i ON i.SNC_ID = f.REG_ID_NET
					INNER JOIN dbo.SystemNetTable j ON j.SN_ID = i.SNC_ID_SN
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE

				WHERE SYS_FILTER = 1
					AND a.REG_UPDATE = 1
					AND f.REG_UPDATE = 1
					AND j.SN_ID <> e.SN_ID

				UNION ALL

				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, f.REG_ID_HOST, 'Изменился тип сети',
					'Был "' + e.SN_NAME + '", стал "' + j.SN_NAME + '"', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, f.REG_WEIGHT - a.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.SystemNetCountTable d ON SNC_ID = REG_ID_NET
					INNER JOIN dbo.SystemNetTable e ON SN_ID = SNC_ID_SN
					INNER JOIN dbo.DistrExchange c ON c.OLD_NUM = a.REG_DISTR_NUM
												AND c.OLD_COMP = a.REG_COMP_NUM
												AND c.OLD_HOST = a.SYS_ID_HOST
					INNER JOIN #dest f ON f.REG_DISTR_NUM = c.NEW_NUM
									AND f.REG_COMP_NUM = c.NEW_COMP
									AND f.SYS_ID_HOST = c.NEW_HOST
					INNER JOIN dbo.SystemNetCountTable i ON i.SNC_ID = f.REG_ID_NET
					INNER JOIN dbo.SystemNetTable j ON j.SN_ID = i.SNC_ID_SN
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE

				WHERE SYS_FILTER = 1
					--AND a.REG_UPDATE = 1
					--AND f.REG_UPDATE = 1
					AND j.SN_ID <> e.SN_ID
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #source q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)
		END

		--5. Включение системы
		/******************************************************
		Строим список включенных систем
		*******************************************************/
		IF @CONNECT = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, f.REG_ID_HOST, 'Включение', '', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, f.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.DistrStatusTable z ON z.DS_ID = a.REG_ID_STATUS
					INNER JOIN #dest f ON f.REG_DISTR_NUM = a.REG_DISTR_NUM
									AND f.REG_COMP_NUM = a.REG_COMP_NUM
									AND f.SYS_ID_HOST = a.SYS_ID_HOST
					INNER JOIN dbo.DistrStatusTable y ON y.DS_ID = f.REG_ID_STATUS
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE f.REG_UPDATE = 1
					AND a.REG_UPDATE = 1
					AND SYS_FILTER = 1
					AND z.DS_ID <> y.DS_ID
					AND y.DS_REG = 0
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #dest q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)

				UNION ALL

				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, f.REG_ID_HOST, 'Включение', '', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, f.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.DistrStatusTable z ON z.DS_ID = a.REG_ID_STATUS
					INNER JOIN dbo.DistrExchange c ON c.OLD_NUM = a.REG_DISTR_NUM
												AND c.OLD_COMP = a.REG_COMP_NUM
												AND c.OLD_HOST = a.SYS_ID_HOST
					INNER JOIN #dest f ON f.REG_DISTR_NUM = c.NEW_NUM
									AND f.REG_COMP_NUM = c.NEW_COMP
									AND f.SYS_ID_HOST = c.NEW_HOST
					INNER JOIN dbo.DistrStatusTable y ON y.DS_ID = f.REG_ID_STATUS
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE SYS_FILTER = 1
					AND z.DS_ID <> y.DS_ID
					AND y.DS_REG = 0
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #source q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)

		--6. Отключение системы
		/******************************************************
		Строим список отключенных систем
		*******************************************************/
		IF @DISCONNECT = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, a.REG_ID_HOST, 'Отключение', '', f.REG_COMMENT,
					f.REG_ID_TYPE, a.REG_PROBLEM, -a.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.DistrStatusTable z ON z.DS_ID = a.REG_ID_STATUS
					INNER JOIN #dest f ON f.REG_DISTR_NUM = a.REG_DISTR_NUM
									AND f.REG_COMP_NUM = a.REG_COMP_NUM
									AND f.SYS_ID_HOST = a.SYS_ID_HOST
					INNER JOIN dbo.DistrStatusTable y ON y.DS_ID = f.REG_ID_STATUS
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE f.REG_UPDATE = 1
					AND a.REG_UPDATE = 1
					AND z.DS_ID <> y.DS_ID
					AND y.DS_REG = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #dest q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)

				UNION ALL

				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, a.REG_ID_HOST, 'Отключение', '', f.REG_COMMENT,
					f.REG_ID_TYPE, a.REG_PROBLEM, -a.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.DistrStatusTable z ON z.DS_ID = a.REG_ID_STATUS
					INNER JOIN dbo.DistrExchange c ON c.OLD_NUM = a.REG_DISTR_NUM
												AND c.OLD_COMP = a.REG_COMP_NUM
												AND c.OLD_HOST = a.SYS_ID_HOST
					INNER JOIN #dest f ON f.REG_DISTR_NUM = c.NEW_NUM
									AND f.REG_COMP_NUM = c.NEW_COMP
									AND f.SYS_ID_HOST = c.NEW_HOST
					INNER JOIN dbo.DistrStatusTable y ON y.DS_ID = f.REG_ID_STATUS
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE z.DS_ID <> y.DS_ID
					AND y.DS_REG = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #source q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)

		--7. Изменение подхоста
		/******************************************************
		Строим список систем, перешедших от одного подхоста к
		другому
		*******************************************************/
		IF @subhost = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, y.SH_ID, 'Изменился подхост',
					'Был "' + z.SH_SHORT_NAME + '", стал "' + y.SH_SHORT_NAME + '"', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, f.REG_WEIGHT - a.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.SubhostTable z ON SH_ID = REG_ID_HOST
					INNER JOIN #dest f ON f.REG_DISTR_NUM = a.REG_DISTR_NUM
									AND f.REG_COMP_NUM = a.REG_COMP_NUM
									AND f.SYS_ID_HOST = a.SYS_ID_HOST
					INNER JOIN dbo.SubhostTable y ON y.SH_ID = f.REG_ID_HOST
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = z.SH_ID
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE f.REG_UPDATE = 1
					AND a.REG_UPDATE = 1
					AND SYS_FILTER = 1
					AND z.SH_ID <> y.SH_ID

				UNION ALL

				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, y.SH_ID, 'Изменился подхост',
					'Был "' + z.SH_SHORT_NAME + '", стал "' + y.SH_SHORT_NAME + '"', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, f.REG_WEIGHT - a.REG_WEIGHT
				FROM
					#source a
					INNER JOIN dbo.SubhostTable z ON SH_ID = REG_ID_HOST
					INNER JOIN dbo.DistrExchange c ON c.OLD_NUM = a.REG_DISTR_NUM
												AND c.OLD_COMP = a.REG_COMP_NUM
												AND c.OLD_HOST = a.SYS_ID_HOST
					INNER JOIN #dest f ON f.REG_DISTR_NUM = c.NEW_NUM
									AND f.REG_COMP_NUM = c.NEW_COMP
									AND f.SYS_ID_HOST = c.NEW_HOST
					INNER JOIN dbo.SubhostTable y ON y.SH_ID = f.REG_ID_HOST
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = z.SH_ID
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE SYS_FILTER = 1
					AND z.SH_ID <> y.SH_ID
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #source q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)

		/******************************************************
		Строим список дистрибутивов, перергистрированных
		на другой хост
		*******************************************************/

		IF @host = 1
			INSERT INTO #rn
					(
						REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
						REG_ID_NET, REG_ID_HOST, REG_TP, REG_NOTE, REG_COMMENT,
						REG_ID_TYPE, REG_PROBLEM, REG_WEIGHT
					)
				SELECT
					a.SYS_ID_HOST, f.REG_ID_SYSTEM, f.REG_DISTR_NUM, f.REG_COMP_NUM,
					f.REG_ID_NET, a.REG_ID_HOST, 'Перерегистрирован на другой хост',
					'', f.REG_COMMENT,
					f.REG_ID_TYPE, f.REG_PROBLEM, 0
				FROM
					#source a
					INNER JOIN dbo.DistrExchange ON OLD_HOST = a.SYS_ID_HOST
										AND OLD_NUM = a.REG_DISTR_NUM
										AND OLD_COMP = a.REG_COMP_NUM
					INNER JOIN #dest f ON NEW_HOST = f.SYS_ID_HOST
								AND NEW_NUM = f.REG_DISTR_NUM
								AND NEW_COMP = f.REG_COMP_NUM
					INNER JOIN #system ON TSYS_ID = a.REG_ID_SYSTEM
					INNER JOIN #subhost ON TSH_ID = a.REG_ID_HOST
					INNER JOIN #system_type ON TSST_ID = a.REG_ID_TYPE
				WHERE SYS_FILTER = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.DistrExchange p
								INNER JOIN #source q ON q.REG_DISTR_NUM = p.NEW_NUM
										AND q.REG_COMP_NUM = p.NEW_COMP
										AND q.SYS_ID_HOST = p.NEW_HOST
							WHERE p.OLD_NUM = a.REG_DISTR_NUM
								AND p.OLD_COMP = a.REG_COMP_NUM
								AND p.OLD_HOST = a.SYS_ID_HOST
						)


		/******************************************************
		Делаем результирующую выборку
		*******************************************************/

		SELECT
			ID, SYS_SHORT_NAME + CASE REG_PROBLEM WHEN 1 THEN ' Пробл.' ELSE '' END AS SYS_SHORT_NAME,
			REG_DISTR_NUM, REG_COMP_NUM,
			SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), REG_DISTR_NUM) +
			CASE REG_COMP_NUM
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), REG_COMP_NUM)
			END AS DIS_STR,
			SST_CAPTION,
			SN_NAME,
			SH_SHORT_NAME, REG_TP, REG_NOTE, REG_COMMENT, CASE RN WHEN 1 THEN REG_WEIGHT ELSE 0 END AS REG_WEIGHT
		FROM
			(
				SELECT
					ID, SYS_SHORT_NAME, REG_PROBLEM, REG_DISTR_NUM, REG_COMP_NUM,
					SST_CAPTION, SN_NAME, SH_SHORT_NAME, REG_TP, SYS_ORDER,
					REG_NOTE, REG_COMMENT, REG_WEIGHT,
					ROW_NUMBER() OVER(PARTITION BY REG_ID_HST, REG_DISTR_NUM, REG_COMP_NUM ORDER BY REG_ID_HOST, REG_DISTR_NUM, REG_COMP_NUM, REG_TP) AS RN
				FROM
					#rn
					INNER JOIN dbo.SystemTable ON SYS_ID = REG_ID_SYSTEM
					INNER JOIN dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
					INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN

					--INNER JOIN dbo.SystemNetTable ON REG_ID_NET = SN_ID
					INNER JOIN dbo.SubhostTable ON SH_ID = REG_ID_HOST
					INNER JOIN dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE
			) AS o_O
		ORDER BY REG_TP, SH_SHORT_NAME, SYS_ORDER, REG_DISTR_NUM, REG_COMP_NUM


		IF OBJECT_ID('tempdb..#system') IS NOT NULL
			DROP TABLE #system

		IF OBJECT_ID('tempdb..#subhost') IS NOT NULL
			DROP TABLE #subhost

		IF OBJECT_ID('tempdb..#system_type') IS NOT NULL
			DROP TABLE #system_type

		IF OBJECT_ID('tempdb..#source') IS NOT NULL
			DROP TABLE #source

		IF OBJECT_ID('tempdb..#dest') IS NOT NULL
			DROP TABLE #dest

		IF OBJECT_ID('tempdb..#problem') IS NOT NULL
			DROP TABLE #problem

		IF OBJECT_ID('tempdb..#hosts') IS NOT NULL
			DROP TABLE #hosts

		IF OBJECT_ID('tempdb..#rn') IS NOT NULL
			DROP TABLE #rn

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_REG_NODE_COMPARE_WEIGHT] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_REG_NODE_COMPARE_WEIGHT] TO rl_reg_report_r;
GO
