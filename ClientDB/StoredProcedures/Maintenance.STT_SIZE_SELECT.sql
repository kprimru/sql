USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[STT_SIZE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[STT_SIZE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[STT_SIZE_SELECT]
	@TOTAL_ROW		INT = NULL OUTPUT,
	@TOTAL_RESERV	VARCHAR(50) = NULL OUTPUT
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

		SELECT
			@TOTAL_ROW = (SELECT row_count FROM Maintenance.DatabaseSize() WHERE obj_name = 'dbo.ClientStat'),
			@TOTAL_RESERV = dbo.FileByteSizeToStr(SUM(reserved))
		FROM Maintenance.DatabaseSize()
		WHERE obj_name IN
			(
				'dbo.ClientStat'
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[STT_SIZE_SELECT] TO rl_maintenance;
GO
