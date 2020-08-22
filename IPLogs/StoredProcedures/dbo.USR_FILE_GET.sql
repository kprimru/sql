USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USR_FILE_GET]
	@FILE_NAME NVARCHAR(512)
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

	    DECLARE @REPORT_PATH VARCHAR(512)

	    SELECT @REPORT_PATH = ST_VALUE
	    FROM dbo.Settings
	    WHERE ST_NAME = 'REPORT_PATH'

	    SELECT UF_USR_NAME, UF_USR_DATA
	    FROM
		    dbo.USRFiles INNER JOIN
		    dbo.Files ON UF_ID_FILE = FL_ID
	    WHERE FL_NAME = @REPORT_PATH + @FILE_NAME

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[USR_FILE_GET] TO rl_client_stat;
GO