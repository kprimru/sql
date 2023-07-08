USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PROCESS_USR_FILES]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PROCESS_USR_FILES]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PROCESS_USR_FILES]
	@FILES		NVarChar(MAX),
	@SERVER		Int = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@XML			Xml

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @XML = CAST(@FILES AS XML);

	    SELECT FILE_PATH
	    FROM
		(
			SELECT 
			    c.value('(@NAME)', 'NVARCHAR(512)') AS FILE_PATH,
			    c.value('(@SIZE)', 'BIGINT') AS FILE_SIZE,
			    c.value('(@TYPE)', 'NVARCHAR(64)') AS FILE_TYPE
		    FROM @xml.nodes('/FILELIST/FILE') AS a(c)
		) AS F
	    WHERE FILE_TYPE = 'USR'
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.Files
					WHERE FL_NAME = FILE_PATH
						AND FL_ID_SERVER = @SERVER
						AND FL_SIZE = FILE_SIZE
				);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PROCESS_USR_FILES] TO rl_ip_refresh;
GO
