USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[FILES_DOWNLOAD_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[FILES_DOWNLOAD_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[FILES_DOWNLOAD_SELECT]
	@SUBHOST	UNIQUEIDENTIFIER,
	@TYPE		NVARCHAR(64)
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

		SELECT USR, DATE
		FROM Subhost.FilesDownload
		WHERE ID_SUBHOST = @SUBHOST
			AND FTYPE = @TYPE
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[FILES_DOWNLOAD_SELECT] TO rl_web_subhost;
GO
