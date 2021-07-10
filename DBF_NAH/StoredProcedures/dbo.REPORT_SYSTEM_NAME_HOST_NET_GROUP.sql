USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_SYSTEM_NAME_HOST_NET_GROUP]
	@statuslist VARCHAR(MAX),
	@subhostlist VARCHAR(MAX),
	@systemlist VARCHAR(MAX),
	@systemtypelist VARCHAR(MAX),
	@systemnetlist VARCHAR(MAX),
	@periodlist VARCHAR(MAX),
	@techtypelist VARCHAR(MAX),
	@selecttotal BIT,
	@selectric BIT
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
		--������� ������� � �������� ������ ��������
		INSERT INTO #dbf_status
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@statuslist, ',')
	END


	IF OBJECT_ID('tempdb..#dbf_system') IS NOT NULL
		DROP TABLE #dbf_system

	CREATE TABLE #dbf_system
		(
			TSYS_ID			INT NOT NULL,
			TSYS_PROBLEM	BIT NOT NULL,
			TSYS_GROUP		VARCHAR(50)
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
					ELSE 0
				END,
				SYS_GROUP
			FROM dbo.SystemTable
			WHERE SYS_REPORT = 1
    END
	ELSE
    BEGIN
		--������� ������� � �������� ������ ��������
		INSERT INTO #dbf_system
			SELECT a.ITEM, CASE
					WHEN EXISTS
						(
							SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = Item
						) THEN 1
					ELSE 0
				END, SYS_GROUP FROM dbo.GET_TABLE_FROM_LIST(@systemlist, ',') a INNER JOIN dbo.SystemTable b ON b.SYS_ID = a.Item
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
		--������� ������� � �������� ������ ��������
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
		--������� ������� � �������� ������ ��������
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
		--������� ������� � �������� ������ ��������
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

  --��� 1. ������� ������� �� ����� ������ (���� ����� ���� ������������� �� �������)

	IF OBJECT_ID('tempdb..#stats') IS NOT NULL
		DROP TABLE #stats

	CREATE TABLE #stats
		(
			PR_ID	SMALLINT,
			SYS_GRP	VARCHAR(50),
			SH_ID	SMALLINT,
			SN_GRP	VARCHAR(50),
			PROBLEM	BIT,
			CNT		INT
		)

	INSERT INTO #stats
		(
			PR_ID, SYS_GRP, SH_ID, SN_GRP, PROBLEM, CNT
		)
		SELECT REG_ID_PERIOD, TSYS_GROUP, REG_ID_HOST, SN_GROUP, PROBLEM, SUM(CNT)
		FROM
			(
				SELECT
					REG_ID_PERIOD, TSYS_GROUP, REG_ID_HOST, CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END AS SN_GROUP,
					CONVERT(BIT,
						/*
						CASE
							WHEN TSYS_PROBLEM = 1
								AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.PeriodRegExceptView b
										INNER JOIN #dbf_system z ON TSYS_ID = b.REG_ID_SYSTEM
										INNER JOIN dbo.DistrStatusTable ON DS_ID = b.REG_ID_STATUS
										INNER JOIN dbo.SystemProblem ON SP_ID_SYSTEM = y.TSYS_ID AND b.REG_ID_SYSTEM = SP_ID_OUT AND SP_ID_PERIOD = b.REG_ID_PERIOD
									WHERE a.REG_COMPLECT = b.REG_COMPLECT AND y.TSYS_ID = b.REG_ID_PERIOD AND DS_REG = 0 AND REG_ID_TYPE <> 6 AND a.REG_ID_SYSTEM <> b.REG_ID_SYSTEM
								) AND EXISTS
								(
									SELECT *
									FROM dbo.SystemProblem
									WHERE SP_ID_SYSTEM = a.REG_ID_SYSTEM
										AND SP_ID_PERIOD = a.REG_ID_PERIOD
								) THEN 1
							ELSE 0
						END*/
						0) AS PROBLEM,
					COUNT(*) AS CNT
				FROM
					dbo.PeriodRegExceptView a
					INNER JOIN #dbf_period ON TPR_ID = REG_ID_PERIOD
					INNER JOIN #dbf_system y ON TSYS_ID = REG_ID_SYSTEM
					INNER JOIN dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
					INNER JOIN #dbf_systemnet ON TSN_ID = SNC_ID_SN
					INNER JOIN #dbf_subhost ON TSH_ID = REG_ID_HOST
					INNER JOIN #dbf_status ON STAT_ID = REG_ID_STATUS
					INNER JOIN #dbf_systemtype ON TST_ID = REG_ID_TYPE
					INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
				GROUP BY REG_ID_PERIOD, TSYS_GROUP, REG_ID_HOST, CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, REG_COMPLECT, TSYS_PROBLEM
			) AS o_O
		GROUP BY REG_ID_PERIOD, TSYS_GROUP, REG_ID_HOST, SN_GROUP, PROBLEM

	CREATE UNIQUE CLUSTERED INDEX IX_STATS ON #stats(PR_ID, SYS_GRP, SH_ID, SN_GRP, PROBLEM)

	DECLARE @sql VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#keys') IS NOT NULL
		DROP TABLE #keys

	CREATE TABLE #keys
		(
			KEY_ID INT IDENTITY(1, 1) PRIMARY KEY,
			KEY_NAME NVARCHAR(64),
			KEY_HOST INT,
			KEY_SYS VARCHAR(50),
			KEY_NET VARCHAR(50),
			KEY_PROBLEM	BIT,
			SN_ORD	SMALLINT,
			SYS_ORD	SMALLINT,
			SH_ORDER	SMALLINT
		)

	IF @selectric = 1
	BEGIN
		IF OBJECT_ID('tempdb..#ric') IS NOT NULL
			DROP TABLE #ric

		CREATE TABLE #ric
			(
				KEY_ID INT IDENTITY(1, 1) PRIMARY KEY,
				KEY_NAME NVARCHAR(64),
				KEY_HOST INT,
				KEY_SYS VARCHAR(50),
				KEY_NET VARCHAR(50),
				KEY_PROBLEM	BIT,
				SN_ORD SMALLINT,
				SYS_ORD	SMALLINT
			)

		INSERT INTO #ric
			SELECT DISTINCT '��� | ' + TSYS_GROUP + CASE TSYS_PROBLEM WHEN 0 THEN '' ELSE ' ����������' END + ' | ' + CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, 0, TSYS_GROUP, CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, TSYS_PROBLEM, MIN(SN_ORDER) AS SN_ORD, MIN(SYS_ORDER) AS SYS_ORDER
			FROM
				dbo.SystemNetTable a
				INNER JOIN #dbf_systemnet c ON c.TSN_ID = a.SN_ID,
				dbo.SystemTable b
				INNER JOIN
					(
						SELECT TSYS_ID, 0 AS TSYS_PROBLEM, TSYS_GROUP
						FROM #dbf_system

						UNION ALL

						SELECT TSYS_ID, 1 AS TSYS_PROBLEM, TSYS_GROUP
						FROM #dbf_system
						WHERE TSYS_PROBLEM = 1
					) d ON d.TSYS_ID = b.SYS_ID
			GROUP BY TSYS_PROBLEM, CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, TSYS_GROUP, TSYS_PROBLEM--, SYS_ORDER
			ORDER BY SYS_ORDER, TSYS_PROBLEM, SN_ORD
    END


	INSERT INTO #keys
		SELECT DISTINCT SH_SHORT_NAME + ' | ' + TSYS_GROUP + ' ' + CASE TSYS_PROBLEM WHEN 0 THEN '' ELSE ' ����������' END + ' | ' + CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, SH_ID, TSYS_GROUP, CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, TSYS_PROBLEM, MIN(SN_ORDER) AS SN_ORD, MIN(SYS_ORDER) AS SYS_ORD, SH_ORDER
		FROM
			dbo.SystemNetTable a
			INNER JOIN #dbf_systemnet d ON d.TSN_ID = a.SN_ID,
			dbo.SystemTable b
			INNER JOIN
				(
					SELECT TSYS_ID, 0 AS TSYS_PROBLEM, TSYS_GROUP
					FROM #dbf_system

					UNION ALL

					SELECT TSYS_ID, 1 AS TSYS_PROBLEM, TSYS_GROUP
					FROM #dbf_system
					WHERE TSYS_PROBLEM = 1
				) e ON e.TSYS_ID = b.SYS_ID,
			dbo.SubhostTable c
			INNER JOIN #dbf_subhost f ON f.TSH_ID = c.SH_ID
		GROUP BY SH_SHORT_NAME, TSYS_PROBLEM, CASE SN_GROUP WHEN '���' THEN '1/�' ELSE SN_GROUP END, SH_ID, TSYS_GROUP, TSYS_PROBLEM, SH_ORDER
		ORDER BY SH_ORDER, SYS_ORD, TSYS_PROBLEM, SN_ORD

	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result

	CREATE TABLE #result
		(
			[����� ������] INT IDENTITY(1,1),
			[����] SMALLDATETIME
		)

	IF @selectric = 1
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

	IF @selectric = 1
		SELECT @sql = @sql +
			' ISNULL(RPVT.[' + CONVERT(VARCHAR, KEY_ID)  + '], 0),'
		FROM #ric
		ORDER BY KEY_ID

	SELECT @sql = @sql + ' ISNULL(KPVT.[' + CONVERT(VARCHAR, KEY_ID)  + '], 0),'
	FROM #keys
	ORDER BY KEY_ID

	-- ������������ ������� �� ���� �������� ��� ��������� �� ���������, ����� ���� � ��������

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
								AND KEY_SYS = SYS_GRP
								AND KEY_NET = SN_GRP
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

	IF @selectric = 1
	BEGIN
		SET @sql = @sql +
		' INNER JOIN
		(
			SELECT a.PR_ID, KEY_ID, PR_DATE, CNT
			FROM
				#stats a
				INNER JOIN dbo.PeriodTable b ON a.PR_ID = b.PR_ID
				INNER JOIN #ric ON KEY_SYS = SYS_GRP
						AND KEY_NET = SN_GRP
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
			[����� �� ���������] INT,
			[������� ����] DECIMAL(10, 4),
			[���] DECIMAL(10, 4),
			[������� ��������] DECIMAL(10, 4),
			[������ �4|��� �� ������] DECIMAL(10, 4),
			[������ �4|��� �� �����] DECIMAL(10, 4),
			[������ �4|������� ���� �� �����] DECIMAL(10, 4),
			[������ �4|������� ���� �� ������] DECIMAL(10, 4),
			[������ �4|������� ��������] DECIMAL(10, 4),
			[������ �4|������� ���� �� ������ %] DECIMAL(10, 4)

	/*
		� ��� ��� ���� �������������� ��� ���� � ��������� ����
	*/

	SET @sql = 'UPDATE #result SET [����� �� ���������] = '
	SELECT @sql = @sql  + '[' + KEY_NAME + ']+'
	FROM #keys

	SET @sql = LEFT(@sql, LEN(@sql) - 1)

	EXEC (@sql)

	IF @selectric = 1
	BEGIN
		SET @sql = 'UPDATE #result SET [������� ����] = '

		SELECT @sql = @sql + 'CONVERT(DECIMAL(8, 4), [' + KEY_NAME + ']) * dbo.GetWeightProblemTmp(''' + CONVERT(VARCHAR(20), KEY_SYS) + ''', ''' + KEY_NET + ''', [����], ' + CONVERT(VARCHAR(20), KEY_PROBLEM) + ') + '
		FROM #ric

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		EXEC (@sql)

		UPDATE #result
		SET [���] = [������� ����]

		DECLARE @i INT

		SELECT @i = MAX([����� ������])
		FROM #result

		WHILE @i <> 1
		BEGIN
			UPDATE #result
			SET [������� ����] = [������� ����] - (SELECT [������� ����] FROM #result WHERE [����� ������] = @i - 1)
			WHERE [����� ������] = @i

			SET @i = @i - 1
		END


		/*
			��������� ������ �4
		*/

		DECLARE @PR_ALG	SMALLINT

		SELECT @PR_ALG = PR_ID
		FROM dbo.PeriodTable
		WHERE PR_DATE = (SELECT MAX([����]) FROM #result)

		DECLARE @PR_JUNE SMALLINT

		SELECT @PR_JUNE = PR_ID
		FROM dbo.PeriodTable
		WHERE PR_DATE = '20130601'

		UPDATE a
		SET [������ �4|��� �� ������] =
				CASE
					WHEN b.PR_DATE >= '20130701' THEN Ric.VKSPGet(@PR_ALG, c.PR_ID, c.PR_ID, c.PR_ID)
					ELSE Ric.VKSPGet(@PR_ALG, c.PR_ID, @PR_JUNE, c.PR_ID)
				END,
			[������ �4|��� �� �����] = Ric.VKSPGet(@PR_ALG, b.PR_ID, b.PR_ID, b.PR_ID)
			/*
				CASE
					WHEN b.PR_DATE >= '20130701' THEN Ric.VKSPGet(@PR_ALG, b.PR_ID, @PR_ALG)
					ELSE Ric.VKSPGet(@PR_ALG, b.PR_ID, @PR_ALG)
				END
			*/
				--Ric.VKSPGet(@PR_ALG, b.PR_ID, @PR_ALG)
		FROM
			#result a
			INNER JOIN dbo.PeriodTable b ON [����] = b.PR_DATE
			INNER JOIN dbo.PeriodTable c ON DATEADD(MONTH, -12, [����]) = c.PR_DATE
		WHERE [����� ������] >= (SELECT MAX([����� ������]) FROM #result) - 15

		UPDATE #result
		SET [������� ��������] =
			(
				SELECT WC_VALUE
				FROM
					Ric.WeightCorrectionMonth
					INNER JOIN dbo.PeriodTable ON PR_ID = WC_ID_PERIOD
				WHERE PR_DATE = [����]
			)

		UPDATE #result
		SET [������ �4|������� ��������] =
			(
				SELECT SUM(WC_VALUE)
				FROM
					Ric.WeightCorrectionMonth
					INNER JOIN dbo.PeriodTable ON PR_ID = WC_ID_PERIOD
				WHERE PR_DATE BETWEEN DATEADD(MONTH, -11, [����]) AND [����]
			)

		UPDATE #result
		SET [������ �4|������� ���� �� ������] = [������ �4|��� �� �����] - [������ �4|��� �� ������]

		UPDATE #result
		SET [������ �4|������� ���� �� ������ %] = 100 * ([������ �4|������� ���� �� ������] + ISNULL([������ �4|������� ��������], 0)) / [������ �4|��� �� ������]

		SELECT @i = MAX([����� ������])
		FROM #result

		WHILE @i <> 1
		BEGIN
			UPDATE #result
			SET [������ �4|������� ���� �� �����] = [������ �4|��� �� �����] - (SELECT [������ �4|��� �� �����] FROM #result WHERE [����� ������] = @i - 1)
			WHERE [����� ������] = @i

			SET @i = @i - 1
		END

		/*
		SET @sql = 'UPDATE a SET [������ �4|��� �� ������] = Ric.VKSPGet(' + CONVERT(VARCHAR(20), @PR_ALG)

		SELECT @sql = @sql + 'CONVERT(DECIMAL(8, 4), b.[' + KEY_NAME + ']) * dbo.GetWeightProblem(' + CONVERT(VARCHAR(20), KEY_SYS) + ', ' + CONVERT(VARCHAR(20), KEY_NET) + ', a.[����], ' + CONVERT(VARCHAR(20), KEY_PROBLEM) + ') + '
		FROM #ric

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + 'FROM #result a INNER JOIN #result b ON a.[����] = DATEADD(MONTH, 12, b.[����])'

		EXEC (@sql)

		UPDATE #result SET [������ �4|������� ����] = [���] - [������ �4|��� �� ������]

		UPDATE #result SET [������ �4|������� ���� %] = 100 * [������ �4|������� ����] / [������ �4|��� �� ������]
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
END
GO
