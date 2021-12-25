USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_FILES_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_FILES_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[USR_FILES_SELECT]
	@LIST	VARCHAR(MAX)
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

		SELECT UF_ID, a.UF_NAME, d.UF_DATA
		FROM
			USR.USRFile a
			INNER JOIN dbo.USR.USRFileData d ON d.UF_ID = a.UF_ID
			INNER JOIN dbo.TableGUIDFromXML(@LIST) ON d.UF_ID = ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_FILES_SELECT] TO rl_usr_collect;
GO
