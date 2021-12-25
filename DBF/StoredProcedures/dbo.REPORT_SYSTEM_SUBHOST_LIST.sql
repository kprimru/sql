USE [DBF]
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
ALTER PROCEDURE [dbo].[REPORT_SYSTEM_SUBHOST_LIST]
	@statuslist VARCHAR(MAX),
	@subhostlist VARCHAR(MAX),
	@systemlist VARCHAR(MAX),
	@systemtypelist VARCHAR(MAX),
	@systemnetlist VARCHAR(MAX),
	@period VARCHAR(MAX),
	@techtypelist VARCHAR(MAX)
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

		IF @statuslist IS NULL
		BEGIN
			INSERT INTO #dbf_status
				SELECT DS_ID
				FROM dbo.DistrStatusTable
				WHERE DS_ACTIVE = 1
		END
		ELSE
		BEGIN
			--парсить строчку и выбирать нужные значения
			INSERT INTO #dbf_status
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@statuslist, ',')
		END


		IF OBJECT_ID('tempdb..#dbf_system') IS NOT NULL
			DROP TABLE #dbf_system

		CREATE TABLE #dbf_system
			(
				TSYS_ID INT NOT NULL
			)

		IF @systemlist IS NULL
		BEGIN
			INSERT INTO #dbf_system
				SELECT SYS_ID
				FROM dbo.SystemTable
				WHERE SYS_ACTIVE = 1
		END
		ELSE
		BEGIN
			--парсить строчку и выбирать нужные значения
			INSERT INTO #dbf_system
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@systemlist, ',')
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

	  --Шаг 1. Создать таблицу со всеми полями (надо чтобы были отсортированы по порядку)
		DECLARE @sql VARCHAR(MAX)

		IF OBJECT_ID('tempdb..#keys') IS NOT NULL
			DROP TABLE #keys

		CREATE TABLE #keys
			(
				KEY_ID INT IDENTITY(1, 1) PRIMARY KEY,
				KEY_NAME NVARCHAR(64),
				KEY_DISTR INT,
				KEY_NET INT,
				SST_ORDER INT,
				SH_ID INT
			)

		INSERT INTO #keys
			SELECT DISTINCT a.SST_CAPTION + ' | ' + SN_NAME, a.SST_ID, SN_ID, a.SST_ORDER, NULL AS SH_ID
			FROM
				dbo.SystemTypeTable a INNER JOIN
				#dbf_systemtype d ON d.TST_ID = a.SST_ID,
				--dbo.SystemTypeTable f ON f.SST_ID = a.SST_ID_SUB,
				dbo.SystemNetTable b INNER JOIN #dbf_systemnet e ON e.TSN_ID = b.SN_ID
			ORDER BY SST_ORDER, /*TT_ID, */SN_ID

		IF OBJECT_ID('tempdb..#final') IS NOT NULL
			DROP TABLE #final

		CREATE TABLE #final
			(
				ID BIGINT IDENTITY(1, 1) PRIMARY KEY,
				IS_GROUP BIT,
				SYS_NAME VARCHAR(250)
			)

		SET @sql = 'ALTER TABLE #final ADD '

		SELECT @sql = @sql + '
				[' + KEY_NAME + '] INT,'
		FROM #keys
		ORDER BY KEY_ID

		SET @sql = LEFT(@sql, LEN(@sql) - 1)
		SET @sql = @sql + '
			'

		EXEC (@sql)

		DECLARE SUBHOST CURSOR LOCAL FOR
			SELECT SH_ID, SH_SHORT_NAME
			FROM
				#dbf_subhost INNER JOIN
				dbo.SubhostTable ON SH_ID = TSH_ID
			ORDER BY SH_ORDER

		DECLARE @shid INT
		DECLARE @shname VARCHAR(50)

		OPEN SUBHOST

		FETCH NEXT FROM SUBHOST INTO @shid, @shname

		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE #keys
			SET SH_ID = @shid

			INSERT INTO #final(IS_GROUP, SYS_NAME)
				SELECT 1, @shname + '    месяц     ' + PR_NAME
				FROM dbo.PeriodTable
				WHERE PR_ID = @period

			SET @sql = '
			INSERT INTO #final
			SELECT 0, KPVT.SYS_NAME AS [Система],'


			SELECT @sql = @sql + ' KPVT.[' + CONVERT(VARCHAR, KEY_ID)  + '],'
			FROM #keys
			ORDER BY KEY_ID

			SET @sql = LEFT(@sql, LEN(@sql) - 1)

			SET @sql = @sql +
				'
					FROM
						(
							SELECT REG_ID_SYSTEM,
								CASE
									WHEN STAT_ID IS NULL
										OR REG_ID_HOST IS NULL
										OR SST_ID IS NULL
										OR SNC_ID IS NULL
										OR y.KEY_ID IS NULL
										--OR (REG_ID_HOST = 12 AND SST_ID = 11)
										THEN NULL
									ELSE REG_ID
								END AS REG_ID,
								z.KEY_ID, SYS_NAME, SYS_ORDER
							FROM 
								dbo.SystemTable INNER JOIN
								#dbf_system ON TSYS_ID = SYS_ID LEFT OUTER JOIN
								dbo.PeriodRegExceptView b ON SYS_ID = REG_ID_SYSTEM AND REG_ID_PERIOD = ' + @period + ' LEFT OUTER JOIN
								dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE LEFT OUTER JOIN
								dbo.SystemNetCountTable d ON d.SNC_ID = b.REG_ID_NET LEFT OUTER JOIN
								#dbf_status	h ON h.STAT_ID = b.REG_ID_STATUS LEFT OUTER JOIN
								#keys z ON KEY_DISTR = SST_ID--_SUB
										AND ISNULL(KEY_NET, SNC_ID_SN) = SNC_ID_SN	LEFT OUTER JOIN
								#keys y ON z.KEY_ID = y.KEY_ID AND y.SH_ID = REG_ID_HOST
							WHERE SYS_REG_NAME <> ''-''
								AND
								NOT EXISTS
								(
									SELECT *
									FROM dbo.DistrExceptTable
									WHERE DE_ID_SYSTEM = REG_ID_SYSTEM
										AND DE_DIS_NUM = REG_DISTR_NUM
										AND DE_COMP_NUM = REG_COMP_NUM
								)
						) KEYS PIVOT
						(
							COUNT(REG_ID)
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

			SET @sql = @sql + '
			ORDER BY KPVT.SYS_ORDER'

			--SELECT @sql
			EXEC (@sql)

			FETCH NEXT FROM SUBHOST INTO @shid, @shname
		END

		SELECT *
		FROM #final

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
		IF OBJECT_ID('tempdb..#keys') IS NOT NULL
			DROP TABLE #keys
		IF OBJECT_ID('tempdb..#ric') IS NOT NULL
			DROP TABLE #ric
		IF OBJECT_ID('tempdb_#final') IS NOT NULL
			DROP TABLE #final

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
