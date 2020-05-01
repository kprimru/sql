USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[SETTINGS_LOAD]
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

		IF NOT EXISTS
			(
				SELECT *
				FROM Common.Settings
				WHERE USR_NAME = ORIGINAL_LOGIN()
			)
			SELECT CAST(SETTINGS AS NVARCHAR(MAX)) AS SETTINGS
			FROM Common.Settings
			WHERE USR_NAME IS NULL
		ELSE
			SELECT CAST(SETTINGS AS NVARCHAR(MAX)) AS SETTINGS
			FROM Common.Settings
			WHERE USR_NAME = ORIGINAL_LOGIN()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Common].[SETTINGS_LOAD] TO public;
GO