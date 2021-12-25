USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_SYSTEM_SUBHOST]
	@statuslist VARCHAR(MAX),
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

		IF @statuslist IS NULL
		BEGIN
			INSERT INTO #dbf_status
			SELECT DS_ID
			FROM dbo.DistrStatusTable
			WHERE DS_ACTIVE = 1
		END
		ELSE
		BEGIN
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
				WHERE SST_ACTIVE = 1
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


		DECLARE @sql VARCHAR(MAX)

		SET @sql = 'SELECT SHPVT.PR_DATE AS [Дата], '

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
					SELECT COUNT(REG_ID)
					FROM 
						#dbf_period	INNER JOIN
						dbo.PeriodRegExceptView b ON TPR_ID = REG_ID_PERIOD INNER JOIN
						dbo.PeriodTable ON PR_ID = REG_ID_PERIOD INNER JOIN
						#dbf_system d ON d.TSYS_ID = b.REG_ID_SYSTEM INNER JOIN
						#dbf_systemtype e ON e.TST_ID = b.REG_ID_TYPE INNER JOIN
						dbo.SystemNetCountTable f ON f.SNC_ID = b.REG_ID_NET INNER JOIN
						#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
						#dbf_status	h ON h.STAT_ID = b.REG_ID_STATUS
					WHERE REG_ID_PERIOD = SSPVT.REG_ID_PERIOD
				) AS [Итого],'

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + ' FROM 
			(
				SELECT REG_ID, REG_ID_HOST, REG_ID_PERIOD, PR_DATE
				FROM 
					#dbf_period INNER JOIN
					dbo.PeriodRegExceptView b ON REG_ID_PERIOD = TPR_ID INNER JOIN
					dbo.PeriodTable ON PR_ID = REG_ID_PERIOD INNER JOIN
					#dbf_system d ON d.TSYS_ID = b.REG_ID_SYSTEM INNER JOIN
					#dbf_systemtype e ON e.TST_ID = b.REG_ID_TYPE INNER JOIN
					dbo.SystemNetCountTable f ON f.SNC_ID = b.REG_ID_NET INNER JOIN
					#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
					#dbf_status	h ON h.STAT_ID = b.REG_ID_STATUS
			) SH
			PIVOT
			(
				COUNT (REG_ID)
				FOR REG_ID_HOST IN
					( '

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, SH_ID) + '],'
		FROM
			dbo.SubhostTable INNER JOIN
			#dbf_subhost ON SH_ID = TSH_ID
		ORDER BY SH_ORDER

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + '
					)
			) AS SHPVT INNER JOIN
			(
				SELECT REG_ID, REG_ID_SYSTEM, REG_ID_PERIOD, PR_DATE
				FROM 
					#dbf_period INNER JOIN
					dbo.PeriodRegExceptView b ON REG_ID_PERIOD = TPR_ID INNER JOIN
					dbo.PeriodTable ON PR_ID = REG_ID_PERIOD INNER JOIN
					#dbf_systemtype c ON c.TST_ID = b.REG_ID_TYPE INNER JOIN
					#dbf_subhost e ON e.TSH_ID = b.REG_ID_HOST INNER JOIN
					dbo.SystemNetCountTable f ON f.SNC_ID = b.REG_ID_NET INNER JOIN
					#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
					#dbf_status	h ON h.STAT_ID = b.REG_ID_STATUS INNER JOIN
					dbo.SystemTypeTable x ON x.SST_ID = b.REG_ID_TYPE
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.SystemTypeSubhost y
						WHERE y.STS_ID_SUBHOST = b.REG_ID_HOST
							AND y.STS_ID_TYPE = x.SST_ID
					)

				UNION ALL

				SELECT REG_ID, REG_ID_SYSTEM, REG_ID_PERIOD, PR_DATE
				FROM 
					#dbf_period INNER JOIN
					dbo.PeriodRegExceptView b ON REG_ID_PERIOD = TPR_ID INNER JOIN
					dbo.PeriodTable ON PR_ID = REG_ID_PERIOD INNER JOIN
					#dbf_systemtype c ON c.TST_ID = b.REG_ID_TYPE INNER JOIN
					#dbf_subhost e ON e.TSH_ID = b.REG_ID_HOST INNER JOIN
					dbo.SystemNetCountTable f ON f.SNC_ID = b.REG_ID_NET INNER JOIN
					#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
					#dbf_status	h ON h.STAT_ID = b.REG_ID_STATUS INNER JOIN
					dbo.SystemTypeTable x ON x.SST_ID = b.REG_ID_TYPE INNER JOIN
					dbo.SystemTypeSubhost y ON y.STS_ID_TYPE = x.SST_ID ON y.STS_ID_SUBHOST = b.REG_ID_HOST
			) SS
			PIVOT
			(
				COUNT (REG_ID)
				FOR REG_ID_SYSTEM IN
					( '

		SELECT @sql = @sql + '[' + CONVERT(VARCHAR, SYS_ID) + '],'
		FROM
			dbo.SystemTable INNER JOIN
			#dbf_system ON SYS_ID = TSYS_ID
		ORDER BY SYS_ORDER

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + '
					)
			) AS SSPVT ON SHPVT.REG_ID_PERIOD = SSPVT.REG_ID_PERIOD
		ORDER BY SSPVT.PR_DATE'

		SET @sql = REPLACE(@sql, '  ', ' ')

		EXEC (@sql)

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END


GO
GRANT EXECUTE ON [dbo].[REPORT_SYSTEM_SUBHOST] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_SYSTEM_SUBHOST] TO rl_reg_report_r;
GO
