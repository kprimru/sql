USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
јвтор:			
ƒата создани€:  	
ќписание:		
*/

CREATE PROCEDURE [dbo].[REPORT_SUBHOST_SYSTEM_LIST]
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
		--парсить строчку и выбирать нужные значени€
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
		--парсить строчку и выбирать нужные значени€
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
			--WHERE SST_REPORT = 1
	END
	ELSE
    BEGIN
		--парсить строчку и выбирать нужные значени€
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
			--WHERE SH_ACTIVE = 1
    END
	ELSE
    BEGIN
		--парсить строчку и выбирать нужные значени€
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
			--WHERE SN_ACTIVE = 1
			ORDER BY SN_ORDER
    END
	ELSE
    BEGIN
		--парсить строчку и выбирать нужные значени€
		INSERT INTO #dbf_systemnet
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@systemnetlist, ',')
    END	

  --Ўаг 1. —оздать таблицу со всеми пол€ми (надо чтобы были отсортированы по пор€дку)	
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
			KEY_SUM SMALLINT
		)
         
	INSERT INTO #keys 
		SELECT CP, SST_ID, SN_ID, SST_ORDER, KEY_SUM
		FROM
			(
				SELECT DISTINCT f.SST_CAPTION + ' | ' + SN_NAME AS CP, f.SST_ID, SN_ID, f.SST_ORDER, 0 AS KEY_SUM
				FROM 
					dbo.SystemTypeTable a INNER JOIN 
					#dbf_systemtype d ON d.TST_ID = a.SST_ID INNER JOIN
					dbo.SystemTypeTable f ON f.SST_ID = a.SST_ID_MOS, 
					dbo.SystemNetTable b INNER JOIN #dbf_systemnet e ON e.TSN_ID = b.SN_ID
				UNION 
				SELECT DISTINCT f.SST_CAPTION + ' | ¬се', f.SST_ID, NULL, f.SST_ORDER, 1 AS KEY_SUM
				FROM 
					dbo.SystemTypeTable a INNER JOIN 
					#dbf_systemtype d ON d.TST_ID = a.SST_ID INNER JOIN
					dbo.SystemTypeTable f ON f.SST_ID = a.SST_ID_MOS
				UNION 
				SELECT DISTINCT f.SST_CAPTION + ' | X', f.SST_ID, NULL, f.SST_ORDER, 2 AS KEY_SUM
				FROM 
					dbo.SystemTypeTable a INNER JOIN 
					#dbf_systemtype d ON d.TST_ID = a.SST_ID INNER JOIN
					dbo.SystemTypeTable f ON f.SST_ID = a.SST_ID_MOS
				UNION 
				SELECT DISTINCT f.SST_CAPTION + ' | %', f.SST_ID, NULL, f.SST_ORDER, 3 AS KEY_SUM
				FROM 
					dbo.SystemTypeTable a INNER JOIN 
					#dbf_systemtype d ON d.TST_ID = a.SST_ID INNER JOIN
					dbo.SystemTypeTable f ON f.SST_ID = a.SST_ID_MOS				
			) AS o_O
		ORDER BY SST_ORDER, ISNULL(SN_ID, 9999), KEY_SUM

	IF OBJECT_ID('tempdb..#final') IS NOT NULL
		DROP TABLE #final
	
	CREATE TABLE #final
		(
			ID BIGINT IDENTITY(1, 1) PRIMARY KEY,
			IS_GROUP BIT,
			IS_FINAL BIT,
			SYS_ID SMALLINT,
			SH_SHORT_NAME VARCHAR(250)
		)

	SET @sql = 'ALTER TABLE #final ADD '

	SELECT @sql = @sql + '
			[' + CONVERT(VARCHAR, KEY_NAME) + '] ' + 
		CASE KEY_SUM 
			WHEN 3 THEN ' FLOAT,'
			ELSE ' INT,'
		END
	FROM #keys
	ORDER BY KEY_ID	
		
	SET @sql = @sql + '
			[-] INT,'
	SET @sql = @sql + '
			[-, X] INT'
	SET @sql = @sql + '
		'		

	EXEC (@sql)	


	IF OBJECT_ID('tempdb..#tempfinal') IS NOT NULL
		DROP TABLE #tempfinal
	
	CREATE TABLE #tempfinal
		(
			ID BIGINT IDENTITY(1, 1) PRIMARY KEY,
			SH_ID SMALLINT,
			SYS_ID SMALLINT
		)

	SET @sql = 'ALTER TABLE #tempfinal ADD '

	SELECT @sql = @sql + '
			[' + CONVERT(VARCHAR, KEY_ID) + '] ' + 
		CASE KEY_SUM 
			WHEN 3 THEN ' FLOAT,'
			ELSE ' INT,'
		END
	FROM #keys
	ORDER BY KEY_ID	
		
	SET @sql = @sql + '
			[-] INT,'
	SET @sql = @sql + '
			[-, X] INT'
	SET @sql = @sql + '
		'			

	EXEC (@sql)	

	SET @sql = 'CREATE INDEX [' + CONVERT(VARCHAR(50), NEWID()) + '] ON #tempfinal(SYS_ID, SH_ID) INCLUDE (ID)'
	EXEC (@sql)

	SET @sql = '
		INSERT INTO #tempfinal
		SELECT KPVT.SH_ID, KPVT.SYS_ID, '

		SELECT @sql = @sql + 
			CASE KEY_SUM
				WHEN 3 THEN 'NULL AS ''[' + CONVERT(VARCHAR, KEY_ID)  + ']'', '
				WHEN 1 THEN 'NULL AS ''[' + CONVERT(VARCHAR, KEY_ID)  + ']'', '
				ELSE ' [' + CONVERT(VARCHAR, KEY_ID)  + '], '
			END
		FROM #keys
		ORDER BY KEY_ID	

		SET @sql = @sql + '0, NULL '

		SET @sql = @sql + 
			'
				FROM
					(
						SELECT SH_ID, SYS_ID, 
							CASE 
								WHEN STAT_ID IS NULL 
									OR REG_ID_HOST IS NULL 
									OR REG_ID_SYSTEM IS NULL
									OR SST_ID IS NULL
									OR SNC_ID IS NULL
									OR KEY_ID IS NULL									
										THEN NULL
								ELSE REG_ID
							END AS REG_ID, z.KEY_ID
						FROM 
							dbo.SystemTable INNER JOIN
							#dbf_system ON SYS_ID = TSYS_ID INNER JOIN
							dbo.SubhostTable ON 1 = 1 INNER JOIN
							#dbf_subhost ON TSH_ID = SH_ID LEFT OUTER JOIN
							dbo.PeriodRegExceptView b ON REG_ID_HOST = SH_ID AND REG_ID_SYSTEM = SYS_ID AND REG_ID_PERIOD = ' + @period + ' LEFT OUTER JOIN	
							dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE LEFT OUTER JOIN
							#dbf_status ON STAT_ID = REG_ID_STATUS LEFT OUTER JOIN
							dbo.SystemNetCountTable d ON d.SNC_ID = b.REG_ID_NET LEFT OUTER JOIN
							#keys z ON KEY_DISTR = SST_ID_MOS									
									AND ISNULL(KEY_NET, SNC_ID_SN) = SNC_ID_SN 
						WHERE NOT EXISTS
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
		WHERE KEY_NET IS NOT NULL
		ORDER BY KEY_ID
	
		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + 
						'	)
			) AS KPVT 
		INNER JOIN 
			(
				SELECT SH_ID, SYS_ID,
					CASE 
						WHEN STAT_ID IS NULL 
							OR REG_ID_HOST IS NULL 
							OR REG_ID_SYSTEM IS NULL
							OR SST_ID IS NULL
							OR SNC_ID IS NULL
							OR KEY_ID IS NULL									
								THEN NULL
							ELSE REG_ID
						END AS REG_ID, z.KEY_ID
				FROM 
					dbo.SystemTable INNER JOIN
					#dbf_system ON SYS_ID = TSYS_ID INNER JOIN
					dbo.SubhostTable ON 1 = 1 INNER JOIN
					#dbf_subhost ON TSH_ID = SH_ID LEFT OUTER JOIN
					dbo.PeriodRegExceptView b ON REG_ID_HOST = SH_ID AND REG_ID_SYSTEM = SYS_ID AND REG_ID_PERIOD = ' + @period + ' LEFT OUTER JOIN
					dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE LEFT OUTER JOIN					
					#dbf_status ON STAT_ID <> REG_ID_STATUS LEFT OUTER JOIN	
					dbo.SystemNetCountTable d ON d.SNC_ID = b.REG_ID_NET LEFT OUTER JOIN
					#keys z ON KEY_DISTR = SST_ID_MOS
				WHERE NOT EXISTS
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
		WHERE KEY_NET IS NULL AND KEY_SUM = 2
		ORDER BY KEY_ID
	
		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + 
						'	)
			) AS KPVM ON KPVM.SH_ID = KPVT.SH_ID AND KPVM.SYS_ID = KPVT.SYS_ID'	

		SET @sql = @sql + ' 
		'
		--SELECT @sql	
		EXEC (@sql)
	
	SET @sql = '
		UPDATE #tempfinal
		SET '
		SELECT @sql = @sql + '
			[' + CONVERT(VARCHAR, KEY_ID) + '] = ' + 
			(
				SELECT '[' + CONVERT(VARCHAR, KEY_ID) + '] +'
				FROM #keys b
				WHERE a.KEY_DISTR = b.KEY_DISTR
					AND b.KEY_SUM = 0
				FOR XML PATH('')
			) + '0,'
		FROM #keys a
		WHERE KEY_SUM = 1
			
		
		SET @sql = LEFT(@sql, LEN(@sql) - 1)
		
		
		--SELECT @sql					
		EXEC (@sql)
	

		


--SELECT *
--FROM #tempfinal


	DECLARE STM CURSOR LOCAL FOR
		SELECT SYS_ID, SYS_NAME
		FROM 
			#dbf_system INNER JOIN
			dbo.SystemTable ON SYS_ID = TSYS_ID
		WHERE SYS_REG_NAME <> '-'
		ORDER BY SYS_ORDER

	DECLARE @sysid INT
	DECLARE @sysname VARCHAR(250)

	OPEN STM

	FETCH NEXT FROM STM INTO @sysid, @sysname

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #final(IS_GROUP, IS_FINAL, SYS_ID, SH_SHORT_NAME)
			SELECT 1, 0, @sysid, @sysname + '    мес€ц     ' + PR_NAME
			FROM dbo.PeriodTable
			WHERE PR_ID = @period
	
		SET @sql = '
		INSERT INTO #final
			(IS_GROUP, IS_FINAL, SYS_ID, SH_SHORT_NAME, '
		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_NAME) + '],'
		FROM #keys 
		--WHERE KEY_SUM <> 3
		ORDER BY KEY_ID

		SET @sql = @sql + '[-], [-, X]'

		SET @sql = @sql + ')
			SELECT 0, 0, SYS_ID, SH_SHORT_NAME, '
		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_ID) + '],'
		FROM #keys 
		--WHERE KEY_SUM <> 3
		ORDER BY KEY_ID

		SET @sql = @sql + '[-], [-, X]
		FROM 
			#tempfinal a INNER JOIN
			dbo.SubhostTable b ON a.SH_ID = b.SH_ID
		WHERE SYS_ID = ' + CONVERT(VARCHAR, @sysid) + '		
		ORDER BY SH_ORDER'

		EXEC (@sql)

		SET @sql = '
		INSERT INTO #final
			(IS_GROUP, IS_FINAL, SYS_ID, SH_SHORT_NAME, '
		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_NAME) + '],'
		FROM #keys 
		WHERE KEY_SUM <> 3
		ORDER BY KEY_ID

		SET @sql = @sql + '[-], [-, X]'

		SET @sql = @sql + ')
			SELECT 0, 1, ' + CONVERT(VARCHAR(20), @sysid) + ', ''»того'', '
		SELECT @sql = @sql + 'SUM([' + CONVERT(VARCHAR, KEY_ID) + ']),'
		FROM #keys 
		WHERE KEY_SUM <> 3
		ORDER BY KEY_ID
		
		SET @sql = @sql + 'SUM([-]), SUM([-, X])
		FROM #tempfinal
		WHERE SYS_ID = ' + CONVERT(VARCHAR, @sysid) + '
		'	
		--SELECT @sql	
		EXEC (@sql)				
		
		SELECT @sql = '
		INSERT INTO #final(IS_GROUP, IS_FINAL, SYS_ID, SH_SHORT_NAME, [' +
			KEY_NAME + '])'
		FROM #keys
		WHERE KEY_ID = 1

		SET @sql = @sql + '
			SELECT 0, 1, ' + CONVERT(VARCHAR(20), @sysid) + ',''¬сего в списке: '', '

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_NAME) + '] +'
		FROM #keys 
		WHERE KEY_SUM = 1 OR KEY_SUM = 2
		ORDER BY KEY_NAME
		
		SET @sql = @sql + '0 
		FROM #final
		WHERE IS_FINAL = 1 AND SYS_ID = ' + CONVERT(VARCHAR, @sysid) + ' '
		--SELECT @sql
		EXEC (@sql)		
	
		FETCH NEXT FROM STM INTO @sysid, @sysname
	END

	CLOSE STM
	DEALLOCATE STM


	SET @sql = '
		UPDATE #final
		SET [-, X] =  '
		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, KEY_NAME) + '] +'
		FROM #keys b
		WHERE KEY_SUM = 2				

		SET @sql = LEFT(@sql, LEN(@sql) - 1)
				
		EXEC (@sql)


		SET @sql = '
		UPDATE #final
		SET '
		SELECT @sql = @sql + '
			[' + CONVERT(VARCHAR, KEY_NAME) + '] = 
			CASE (' + 
			(
				SELECT '[' + CONVERT(VARCHAR, KEY_NAME) + ']'
				FROM #keys b
				WHERE KEY_SUM = 1 AND a.KEY_DISTR = b.KEY_DISTR
			) + ' + ' +
			(
				SELECT '[' + CONVERT(VARCHAR, KEY_NAME) + ']'
				FROM #keys b
				WHERE KEY_SUM = 2 AND a.KEY_DISTR = b.KEY_DISTR
			) + ')
				WHEN 0 THEN 0
				ELSE
			 ROUND(100 * CONVERT(FLOAT, ' + 
			(
				SELECT '[' + CONVERT(VARCHAR, KEY_NAME) + ']'
				FROM #keys b
				WHERE KEY_SUM = 2 AND a.KEY_DISTR = b.KEY_DISTR
			) + ')/(' + 
			(
				SELECT '[' + CONVERT(VARCHAR, KEY_NAME) + ']'
				FROM #keys b
				WHERE KEY_SUM = 1 AND a.KEY_DISTR = b.KEY_DISTR
			) + ' + ' +
			(
				SELECT '[' + CONVERT(VARCHAR, KEY_NAME) + ']'
				FROM #keys b
				WHERE KEY_SUM = 2 AND a.KEY_DISTR = b.KEY_DISTR
			) + '), 1) END,' 
		FROM #keys a
		WHERE KEY_SUM = 3
		
		SET @sql = LEFT(@sql, LEN(@sql) - 1)
		
		--SELECT @sql					
		EXEC (@sql)
	


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
	IF OBJECT_ID('tempdb_#tempfinal') IS NOT NULL
		DROP TABLE #tempfinal
END
