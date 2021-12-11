USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USERS_ACTIVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USERS_ACTIVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[USERS_ACTIVE]
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

		IF OBJECT_ID('tempdb..#active') IS NOT NULL
			DROP TABLE #active

		CREATE TABLE #active
			(
				SP_ID		INT,
				LOGIN_NAME	NVARCHAR(128),
				PROG_NAME	NVARCHAR(128),
				HST_NAME	NVARCHAR(128),
				LOGIN_TIME	DATETIME,
				LAST_BATCH	DATETIME,
				LOGIN_DELTA	NVARCHAR(128),
				BATCH_DELTA	NVARCHAR(128)
			)

		INSERT INTO #active(SP_ID, LOGIN_NAME, PROG_NAME, HST_NAME, LOGIN_TIME, LAST_BATCH, LOGIN_DELTA, BATCH_DELTA)
			SELECT
				b.spid,
				a.login_name, a.program_name, a.host_name, a.login_time, /*cpu_time, logical_reads, */last_batch,
				dbo.TimeSecToStr(DATEDIFF(second, a.login_time, GETDATE())) AS login_delta,
				dbo.TimeSecToStr(DATEDIFF(second, b.last_batch, GETDATE())) AS batch_delta
			FROM
				sys.dm_exec_sessions a
				INNER JOIN master.dbo.sysprocesses b ON a.session_id = b.spid
			WHERE is_user_process = 1

		SELECT TOP 1 LOGIN_NAME AS ID, LOGIN_NAME AS ID_MASTER, SP_ID, LOGIN_NAME, PROG_NAME, HST_NAME, LOGIN_TIME, LAST_BATCH, LOGIN_DELTA, BATCH_DELTA
		FROM #active
		WHERE 1 = 0

		UNION ALL

		SELECT DISTINCT LOGIN_NAME, NULL, NULL, LOGIN_NAME, NULL, HST_NAME, NULL, NULL, NULL, NULL
		FROM #active

		UNION ALL

		SELECT CONVERT(NVARCHAR(128), NEWID()), LOGIN_NAME, SP_ID, NULL AS LOGIN_NAME, PROG_NAME, HST_NAME, LOGIN_TIME, LAST_BATCH, LOGIN_DELTA, BATCH_DELTA
		FROM #active

		ORDER BY LOGIN_NAME, HST_NAME, PROG_NAME, LAST_BATCH

		IF OBJECT_ID('tempdb..#active') IS NOT NULL
			DROP TABLE #active

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USERS_ACTIVE] TO rl_maintenance;
GO
