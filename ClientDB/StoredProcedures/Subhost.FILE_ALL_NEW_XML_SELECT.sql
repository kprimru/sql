USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[FILE_ALL_NEW_XML_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[FILE_ALL_NEW_XML_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[FILE_ALL_NEW_XML_SELECT]
	@SH		NVARCHAR(16),
	@USR	NVARCHAR(128) = NULL
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

		EXEC dbo.SUBHOST_EXPORT_DATA_NEW @SH

		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'ALL'
			FROM dbo.Subhost
			WHERE SH_REG = @SH
				AND @USR IS NOT NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[FILE_ALL_NEW_XML_SELECT] TO rl_web_subhost;
GO
