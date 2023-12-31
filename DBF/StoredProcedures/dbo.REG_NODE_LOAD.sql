USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_NODE_LOAD]
	@filename VARCHAR(MAX),
	@cnt INT = NULL OUTPUT
WITH EXECUTE AS OWNER
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

		--��� 1. ��������� �� �� ������ � ������ /outcsv
		DECLARE @bcppath VARCHAR(MAX)

		SET @bcppath = dbo.GET_SETTING('BCP_PATH')

		--��� 2. �������� ������ �� ��������� �������

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
		(
			REG_SYSTEM VARCHAR(20),
			REG_DISTR INT,
			REG_COMP TINYINT,
			REG_SYSTEM_TYPE VARCHAR(20),
			REG_TECH_TYPE INT,
			REG_NET INT,
			REG_SUBHOST BIT,
			REG_TRANS_COUNT INT,
			REG_TRANS_LEFT INT,
			REG_STATUS INT,
			REG_DATE VARCHAR(20),
			REG_FIRST_REG	VARCHAR(20),
			REG_COMMENT VARCHAR(150),
			REG_COMPLECT VARCHAR(50) ,
			REG_REPORT_CODE VARCHAR(10),
			REG_REPORT_VALUE VARCHAR(50),
			REG_SHORT VARCHAR(10),
			REG_MAIN TINYINT,
			REG_SUB	TINYINT,
			REG_OFFLINE	VARCHAR(50),
			REG_YUBIKEY	VARCHAR(50),
			REG_KRF		VARCHAR(50),
			REG_KRF1	VARCHAR(50),
			REG_PARAM	VARCHAR(50),
			REG_ODON	VARCHAR(50),
			REG_ODOFF	VARCHAR(50),
		)

		DECLARE @sql NVARCHAR(4000)

		SET @sql = '
		BULK INSERT #temp
		FROM ''' + @filename + '''
		WITH
			(
			FORMATFILE = ''' + @bcppath + ''',
			FIRSTROW = 2
			)'
		--SELECT 1 AS ER_MSG, @sql
		EXEC sp_executesql @sql
		--��� 3. �� ��������� ������� ��������� ������ � ������� ������� ������� �� ����� ���������.

		UPDATE #temp
		SET REG_COMMENT = REPLACE(LEFT(RIGHT(REG_COMMENT, LEN(REG_COMMENT) - 1), LEN(REG_COMMENT) - 2), '""', '"')
		WHERE SUBSTRING(REG_COMMENT, 1, 1) = '"' AND SUBSTRING(REG_COMMENT, LEN(REG_COMMENT), 1) = '"'

		UPDATE #temp
		SET REG_COMMENT = ''
		WHERE REG_COMMENT IS NULL

		UPDATE #temp
		SET REG_ODON = 0
		WHERE REG_ODON IS NULL

		UPDATE #temp
		SET REG_ODOFF = 0
		WHERE REG_ODOFF IS NULL

		--DELETE FROM #temp WHERE REG_COMMENT NOT LIKE '(�1)%' AND REG_COMMENT NOT LIKE '(�)%'

		TRUNCATE TABLE dbo.RegNodeFullTable

		--DBCC CHECKIDENT(RegNodeFullTable, RESEED, 1)

		--SELECT * FROM #temp ORDER BY REG_COMMENT
		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
		(
			ER_MSG VARCHAR(255),
			ER_TYPE	TINYINT
		)

		INSERT INTO #tmp
			SELECT '����������� ������� "' + REG_SYSTEM + '". ' + REG_SYSTEM + ' ' + CONVERT(VARCHAR, REG_DISTR), 1
			FROM (
				SELECT DISTINCT REG_SYSTEM, REG_DISTR
				FROM #temp
				WHERE NOT EXISTS	(
									SELECT *
									FROM dbo.SystemTable
									WHERE SYS_REG_NAME = REG_SYSTEM
									)
				) AS dt
			ORDER BY REG_SYSTEM

		INSERT INTO #tmp
			SELECT '����������� ��� ������� "' + REG_SYSTEM_TYPE + '". ' + REG_SYSTEM + ' ' + CONVERT(VARCHAR, REG_DISTR), 1
			FROM (
				SELECT DISTINCT REG_SYSTEM_TYPE, REG_SYSTEM, REG_DISTR
				FROM #temp
				WHERE NOT EXISTS	(
									SELECT *
									FROM dbo.SystemTypeTable
									WHERE SST_NAME = REG_SYSTEM_TYPE
									)
				) AS dt
			ORDER BY REG_SYSTEM_TYPE

		INSERT INTO #tmp
			SELECT '����������� ������� "' + REG_COMMENT + '". ' + REG_SYSTEM + ' ' + CONVERT(VARCHAR, REG_DISTR), 1
			FROM (
				SELECT DISTINCT dbo.GET_HOST_BY_COMMENT2(REG_COMMENT, REG_DISTR, REG_SYSTEM) AS REG_COMMENT, REG_SYSTEM, REG_DISTR
				FROM #temp
				WHERE NOT EXISTS	(
									SELECT *
									FROM dbo.SubhostTable
									WHERE SH_LST_NAME = dbo.GET_HOST_BY_COMMENT2(REG_COMMENT, REG_DISTR, REG_SYSTEM)
										AND SH_REG = 1
									)
				) AS dt

		INSERT INTO #tmp
			SELECT '����������� ���������� ������� ������� "' + CONVERT(VARCHAR,REG_NET) + '/' + CONVERT(VARCHAR,REG_TECH_TYPE) + '" ����=' + ISNULL(REG_ODON, '') + '  ����=' + ISNULL(REG_ODOFF, '') + '. ' + REG_SYSTEM + ' ' + CONVERT(VARCHAR, REG_DISTR), 1
			FROM (
				SELECT DISTINCT REG_NET, REG_TECH_TYPE, REG_SYSTEM, REG_DISTR, REG_ODON, REG_ODOFF
				FROM #temp
				WHERE NOT EXISTS	(
									SELECT	*
									FROM	dbo.SystemNetCountTable
									WHERE	SNC_NET_COUNT = REG_NET
										AND SNC_TECH = REG_TECH_TYPE
										AND SNC_ODON = REG_ODON
										AND SNC_ODOFF = REG_ODOFF
									)
				) AS dt
			ORDER BY REG_NET

		INSERT INTO #tmp
			SELECT '����������� ������ ������������ "' + CONVERT(VARCHAR,REG_STATUS) + '". ' + REG_SYSTEM + ' ' + CONVERT(VARCHAR, REG_DISTR), 1
			FROM (
				SELECT DISTINCT REG_STATUS, REG_SYSTEM, REG_DISTR
				FROM #temp
				WHERE NOT EXISTS	(
									SELECT	*
									FROM	dbo.DistrStatusTable
									WHERE	DS_REG = REG_STATUS
									)
				) AS dt
			ORDER BY REG_STATUS

		INSERT INTO #tmp
			SELECT '�������� ������� ��������. '  + REG_SYSTEM + ' ' + CONVERT(VARCHAR, REG_DISTR), 2
			FROM
				(
					SELECT DISTINCT
						REG_SYSTEM, REG_DISTR
					FROM
						#temp
						INNER JOIN dbo.SubhostTable ON SH_LST_NAME = dbo.GET_HOST_BY_COMMENT2(REG_COMMENT, REG_DISTR, REG_SYSTEM)
					WHERE SH_SUBHOST <> REG_SUBHOST AND REG_DISTR <> 20
						AND REG_STATUS = 0
						AND REG_COMPLECT IS NOT NULL
				) AS dt


		IF (SELECT COUNT(*) FROM #tmp WHERE ER_TYPE = 1) > 0
			SELECT
				CASE ER_TYPE
					WHEN 1 THEN '������'
					WHEN 2 THEN '��������������'
				END + '. ' + ER_MSG AS ER_MSG
			FROM #tmp
		ELSE
			BEGIN

			INSERT INTO dbo.RegNodeFullTable(RN_ID_SYSTEM, RN_DISTR_NUM, RN_COMP_NUM,
										RN_ID_TYPE, /*RN_ID_TECH_TYPE, */RN_ID_NET, RN_SUBHOST,
										RN_ID_SUBHOST, RN_TRANSFER_COUNT, RN_TRANSFER_LEFT,
										RN_ID_STATUS, RN_REG_DATE, RN_FIRST_REG,
										RN_COMMENT, RN_COMPLECT, RN_REPORT_CODE,
										RN_REPORT_VALUE, RN_SHORT, RN_MAIN, RN_OFFLINE,
										RN_YUBIKEY, RN_KRF, RN_KRF1, RN_PARAM, RN_ODON, RN_ODOFF
										)
			/*
			SELECT	dbo.RN_GET_SYS_ID(REG_SYSTEM), REG_DISTR, REG_COMP,
					dbo.RN_GET_SYSTEM_TYPE(REG_SYSTEM_TYPE),
					dbo.RN_GET_TECHNOL_TYPE_ID(REG_TECH_TYPE), dbo.RN_GET_NET_ID(REG_NET),
					REG_SUBHOST, dbo.RN_GET_SUBHOST_ID(REG_COMMENT, REG_SUBHOST),
					REG_TRANS_COUNT, REG_TRANS_LEFT, dbo.RN_GET_STATUS_ID(REG_STATUS),
					dbo.RN_GET_DATE(REG_DATE), ISNULL(REG_COMMENT, ''), ISNULL(REG_COMPLECT, '')
			FROM #temp
			*/

			SELECT
					--dbo.RN_GET_SYS_ID(REG_SYSTEM),
					SYS_ID,
					REG_DISTR, REG_COMP,
					--dbo.RN_GET_SYSTEM_TYPE(REG_SYSTEM_TYPE),
					SST_ID,
					--dbo.RN_GET_TECHNOL_TYPE_ID(REG_TECH_TYPE),
					--TT_ID,
					--dbo.RN_GET_NET_ID(REG_NET),
					SNC_ID,
					REG_SUBHOST, SH_ID,
					--dbo.RN_GET_SUBHOST_ID(REG_COMMENT, REG_SUBHOST),
					REG_TRANS_COUNT, REG_TRANS_LEFT,
					--dbo.RN_GET_STATUS_ID(REG_STATUS),
					DS_ID,
					--dbo.RN_GET_DATE(REG_DATE),
					CASE ISDATE(REG_DATE)
						WHEN 1 THEN	CONVERT(DATETIME, REG_DATE, 104)
						ELSE '19000101'
					END,
					CASE ISDATE(REG_FIRST_REG)
						WHEN 1 THEN	CONVERT(DATETIME, REG_DATE, 104)
						ELSE '19000101'
					END,
					ISNULL(REG_COMMENT, ''), ISNULL(REG_COMPLECT, ''),
					REG_REPORT_CODE, REG_REPORT_VALUE, REG_SHORT, REG_MAIN,
					REG_OFFLINE, REG_YUBIKEY, REG_KRF, REG_KRF1, REG_PARAM, REG_ODON, REG_ODOFF
			FROM
				#temp
				INNER JOIN dbo.SystemTable ON SYS_REG_NAME = REG_SYSTEM
				INNER JOIN dbo.SystemTypeTable ON SST_NAME = REG_SYSTEM_TYPE
				INNER JOIN dbo.SystemNetCountTable ON SNC_NET_COUNT = REG_NET AND SNC_TECH = REG_TECH_TYPE AND SNC_ODON = REG_ODON AND SNC_ODOFF = REG_ODOFF
				INNER JOIN
				dbo.SubhostTable ON SH_REG = 1 AND SH_LST_NAME = dbo.GET_HOST_BY_COMMENT2(REG_COMMENT, REG_DISTR, REG_SYSTEM)
				    /*
					CASE
						WHEN CHARINDEX('(', REG_COMMENT) <> 1 THEN ''
						WHEN CHARINDEX(')', SUBSTRING(REG_COMMENT, CHARINDEX('(', REG_COMMENT) + 1,
										LEN(REG_COMMENT) - CHARINDEX('(', REG_COMMENT))) < 2 THEN ''
						ELSE
							SUBSTRING(SUBSTRING(REG_COMMENT, CHARINDEX('(', REG_COMMENT) + 1,
								LEN(REG_COMMENT) - CHARINDEX('(', REG_COMMENT)), 1, CHARINDEX(')', SUBSTRING(REG_COMMENT, CHARINDEX('(', REG_COMMENT) + 1,
								LEN(REG_COMMENT) - CHARINDEX('(', REG_COMMENT))) - 1)
					END
					*/
					 INNER JOIN
				dbo.DistrStatusTable ON DS_REG = REG_STATUS

			SET @cnt = @@ROWCOUNT

			IF (SELECT COUNT(*) FROM #tmp WHERE ER_TYPE = 2) > 0
				SELECT
					CASE ER_TYPE
						WHEN 1 THEN '������'
						WHEN 2 THEN '��������������'
					END + '. ' + ER_MSG AS ER_MSG
				FROM #tmp
			ELSE
				SELECT '0' AS ER_MSG
		END


		DROP TABLE #temp

		IF @cnt IS NULL
			SET @cnt = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REG_NODE_LOAD] TO rl_reg_node_w;
GO
