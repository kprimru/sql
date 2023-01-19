USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FILES_LOG_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FILES_LOG_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[FILES_LOG_SELECT]
	@BEGIN		DATETIME,
	@END		DATETIME
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
		    FL_ID, FL_NAME,
		    CONVERT(DECIMAL(24, 8), CONVERT(DECIMAL(24, 8), FL_SIZE) / 1024) AS FL_SIZE,
		    FL_DATE
	    FROM dbo.Files
	    WHERE FL_TYPE = 1
		    AND (FL_DATE >= @BEGIN OR @BEGIN IS NULL)
		    AND (FL_DATE <= @END OR @END IS NULL)
	    ORDER BY FL_DATE DESC

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FILES_LOG_SELECT] TO rl_files_log;
GO
