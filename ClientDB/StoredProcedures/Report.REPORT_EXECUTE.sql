USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[REPORT_EXECUTE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[REPORT_EXECUTE]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[REPORT_EXECUTE]
	@ID		UNIQUEIDENTIFIER,
	@PARAM	NVARCHAR(MAX)
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

		DECLARE @SCHEMA NVARCHAR(128)
		DECLARE @PROC	NVARCHAR(128)

		SELECT @SCHEMA = REP_SCHEMA, @PROC = REP_PROC
		FROM Report.Reports
		WHERE ID = @ID

		IF ISNULL(@SCHEMA, '') = '' OR ISNULL(@PROC, '') = ''
			RETURN

		INSERT INTO Report.ExecutionLog(ID_REPORT)
			VALUES(@ID)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'EXEC [' + @SCHEMA + '].[' + @PROC + '] @PARAM'

		EXEC sp_executesql @SQL, N'@PARAM NVARCHAR(MAX)', @PARAM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[REPORT_EXECUTE] TO rl_report;
GO
