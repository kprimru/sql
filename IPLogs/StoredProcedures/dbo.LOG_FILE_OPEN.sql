USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[LOG_FILE_OPEN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[LOG_FILE_OPEN]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[LOG_FILE_OPEN]
	@FILENAME	NVarChar(256),
	@SERVER		Int
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
		    S.[SRV_PATH] + F.[FL_NAME] AS [FL_NAME], [FL_SIZE], [FL_DATE],
		    [LF_TEXT]
	    FROM [dbo].[Files] AS F
		INNER JOIN [dbo].[LogFiles] AS L ON L.[LF_ID_FILE] = F.[FL_ID]
		INNER JOIN [dbo].[Servers] AS S ON S.[SRV_ID] = F.[FL_ID_SERVER]
	    WHERE F.[FL_NAME] = @FILENAME
			AND F.[FL_ID_SERVER] = @SERVER;

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[LOG_FILE_OPEN] TO rl_client_stat;
GO
