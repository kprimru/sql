USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ERR_LOG_FILE_OPEN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ERR_LOG_FILE_OPEN]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ERR_LOG_FILE_OPEN]
	@FILENAME	NVARCHAR(256)
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
		    FL_NAME, FL_SIZE, FL_DATE,
		    ERROR_DATA AS LF_TEXT
	    FROM
		    dbo.Files INNER JOIN
		    dbo.USRFiles ON UF_ID_FILE = FL_ID INNER JOIN
		    dbo.ConsErr ON UF_ID = ID_USR
	    WHERE FL_NAME = @FILENAME

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ERR_LOG_FILE_OPEN] TO rl_client_stat;
GO
