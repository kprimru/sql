USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USR_FILE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USR_FILE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[USR_FILE_GET]
	@FILE_NAME	NVarChar(512),
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

	    SELECT UF_USR_NAME, UF_USR_DATA
	    FROM
		    dbo.USRFiles INNER JOIN
		    dbo.Files ON UF_ID_FILE = FL_ID
	    WHERE FL_NAME = @FILE_NAME
			AND FL_ID_SERVER = @SERVER;

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
