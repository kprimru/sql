USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[REPORT_NEW_SYSTEM_LIST]
  @subhostlist VARCHAR(MAX),
  @systemlist VARCHAR(MAX),
  @systemtypelist VARCHAR(MAX),
  @systemnetlist VARCHAR(MAX),
  @periodlist VARCHAR(MAX),
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
			INSERT INTO #dbf_system
				SELECT SYS_ID, SYS_ID_HOST FROM dbo.GET_TABLE_FROM_LIST(@systemlist, ',') INNER JOIN dbo.SystemTable ON SYS_ID = Item
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

		SELECT
			PR_DATE, RNN_DATE_ON, RNN_DATE,	SYS_SHORT_NAME, RNN_DISTR_NUM, RNN_COMP_NUM,
			SH_LST_NAME, SST_LST, SNC_NET_COUNT
		FROM
			dbo.PeriodRegNewTable b INNER JOIN
			dbo.PeriodTable a ON a.PR_ID = b.RNN_ID_PERIOD INNER JOIN
			dbo.SystemTable c ON c.SYS_ID = b.RNN_ID_SYSTEM INNER JOIN
			dbo.SystemTypeTable d ON d.SST_ID = b.RNN_ID_TYPE INNER JOIN
			dbo.SubhostTable e ON e.SH_ID = b.RNN_ID_HOST INNER JOIN
			dbo.SystemNetCountTable f ON f.SNC_ID = b.RNN_ID_NET INNER JOIN
			#dbf_systemnet g ON g.TSN_ID = f.SNC_ID_SN INNER JOIN
			#dbf_system h ON h.TSYS_ID = c.SYS_ID INNER JOIN
			#dbf_subhost j ON j.TSH_ID = e.SH_ID INNER JOIN
			#dbf_systemtype k ON k.TST_ID = d.SST_ID INNER JOIN
			#dbf_period	l ON l.PR_ID = a.PR_ID
		WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.DistrExchange
					WHERE NEW_HOST = HST_ID
						AND NEW_NUM = RNN_DISTR_NUM
						AND NEW_COMP = RNN_COMP_NUM
				)
		ORDER BY SYS_ORDER, RNN_DISTR_NUM, RNN_COMP_NUM


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
GRANT EXECUTE ON [dbo].[REPORT_NEW_SYSTEM_LIST] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_NEW_SYSTEM_LIST] TO rl_reg_report_r;
GO