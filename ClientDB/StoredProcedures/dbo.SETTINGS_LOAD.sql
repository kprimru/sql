USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SETTINGS_LOAD]
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
				FROM dbo.Settings
				WHERE ST_USER = ORIGINAL_LOGIN()
					AND ST_HOST = HOST_NAME()
			)
			SELECT
				ST_CLIENT, ST_MENU, ST_EXT_SEARCH,

				ST_CA_STATUS, ST_CA_CATEGORY, ST_CA_INN, ST_CA_SERVICE, ST_CA_ACTIVITY, ST_CA_PAPPER, ST_CA_GRAPH,

				ST_EXP_NUM, ST_EXP_NAME, ST_EXP_ADDRESS, ST_EXP_INN,
				ST_EXP_DIR, ST_EXP_BUH, ST_EXP_RES,
				ST_EXP_TYPE, ST_EXP_PERSONAL,
				ST_EXP_BOOK, ST_EXP_PAPPER,
				ST_EXP_STATUS, ST_EXP_SYSTEM,

				ST_SR_VISIBLE, ST_SR_COUNT, ST_SR_SAVE,

				ST_REP_SAVE, ST_REP_TYPE, ST_REP_PATH,

				ST_OFFER_PATH,

				ST_DEBUG
			FROM dbo.Settings
			WHERE ST_USER IS NULL
				AND ST_HOST IS NULL
		ELSE
			SELECT
				ST_CLIENT, ST_MENU, ST_EXT_SEARCH,

				ST_CA_STATUS, ST_CA_CATEGORY, ST_CA_INN, ST_CA_SERVICE, ST_CA_ACTIVITY, ST_CA_PAPPER, ST_CA_GRAPH,

				ST_EXP_NUM, ST_EXP_NAME, ST_EXP_ADDRESS, ST_EXP_INN,
				ST_EXP_DIR, ST_EXP_BUH, ST_EXP_RES,
				ST_EXP_TYPE, ST_EXP_PERSONAL,
				ST_EXP_BOOK, ST_EXP_PAPPER,
				ST_EXP_STATUS, ST_EXP_SYSTEM,

				ST_SR_VISIBLE, ST_SR_COUNT, ST_SR_SAVE,

				ST_REP_SAVE, ST_REP_TYPE, ST_REP_PATH,

				ST_OFFER_PATH,

				ST_DEBUG
			FROM dbo.Settings
			WHERE ST_USER = ORIGINAL_LOGIN()
				AND ST_HOST = HOST_NAME()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SETTINGS_LOAD] TO public;
GO