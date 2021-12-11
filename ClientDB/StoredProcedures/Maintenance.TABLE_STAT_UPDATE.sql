USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[TABLE_STAT_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[TABLE_STAT_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[TABLE_STAT_UPDATE]
	@TABLE_NAME	NVARCHAR(512)
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

		DECLARE @SQL	NVARCHAR(MAX)

		SET @SQL = N'UPDATE STATISTICS ' + @TABLE_NAME + N' WITH FULLSCAN'
		EXEC (@SQL)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[TABLE_STAT_UPDATE] TO rl_maintenance;
GO
