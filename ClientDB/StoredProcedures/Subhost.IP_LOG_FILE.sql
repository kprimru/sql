USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[IP_LOG_FILE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[IP_LOG_FILE]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [Subhost].[IP_LOG_FILE]
	@FILE	NVARCHAR(512)
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

		SELECT LF_TEXT
		FROM IP.LogFileView
		WHERE FL_NAME = @FILE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[IP_LOG_FILE] TO rl_web_subhost;
GO
