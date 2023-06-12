﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SETTINGS_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SETTINGS_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SETTINGS_SAVE]
	@CLIENT			BIT = 0,
	@MENU			BIT = 0,
	@EXT_SEARCH		BIT = 1,
	@CA_STATUS		BIT = 1,
	@CA_CATEG		BIT = 1,
	@CA_INN			BIT = 1,
	@CA_SERVICE		BIT	= 1,
	@CA_ACTIVITY	BIT = 1,
	@CA_PAPPER		BIT = 1,
	@CA_GRAPH		BIT = 1,
	@EXP_NUM		BIT = 1,
	@EXP_NAME		BIT = 1,
	@EXP_ADDRESS	BIT = 1,
	@EXP_INN		BIT = 1,
	@EXP_DIR		BIT = 1,
	@EXP_BUH		BIT = 1,
	@EXP_RES		BIT = 1,
	@EXP_TYPE		BIT = 1,
	@EXP_PERSONAL	BIT = 1,
	@EXP_BOOK		BIT = 1,
	@EXP_PAPPER		BIT = 1,
	@EXP_STATUS		BIT = 1,
	@EXP_SYSTEM		BIT = 1,
	@SR_VISIBLE		BIT = 1,
	@SR_COUNT		INT = 0,
	@SR_SAVE		BIT = 1,
	@REP_SAVE		BIT = 1,
	@REP_TYPE		TINYINT = 1,
	@REP_PATH		NVARCHAR(512) = '',
	@OFFER_PATH		NVARCHAR(512) = '',
	@DEBUG			BIT = 0,
	@EXCEL_LONG     Bit = 1,
	@FONT_SIZE		TinyInt = 8,
	@CLOSE_QUERY	Bit = 1
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

		UPDATE dbo.Settings
		SET ST_CLIENT = @CLIENT,
			ST_MENU = @MENU,
			ST_EXT_SEARCH = @EXT_SEARCH,

			ST_CA_STATUS = @CA_STATUS,
			ST_CA_CATEGORY = @CA_CATEG,
			ST_CA_INN = @CA_INN,
			ST_CA_SERVICE = @CA_SERVICE,
			ST_CA_ACTIVITY = @CA_ACTIVITY,
			ST_CA_PAPPER = @CA_PAPPER,
			ST_CA_GRAPH = @CA_GRAPH,

			ST_EXP_NUM = @EXP_NUM,
			ST_EXP_NAME = @EXP_NAME,
			ST_EXP_ADDRESS = @EXP_ADDRESS,
			ST_EXP_INN = @EXP_INN,
			ST_EXP_DIR = @EXP_DIR,
			ST_EXP_BUH = @EXP_BUH,
			ST_EXP_RES = @EXP_RES,
			ST_EXP_TYPE = @EXP_TYPE,
			ST_EXP_PERSONAL = @EXP_PERSONAL,
			ST_EXP_BOOK = @EXP_BOOK,
			ST_EXP_PAPPER = @EXP_PAPPER,
			ST_EXP_STATUS = @EXP_STATUS,
			ST_EXP_SYSTEM = @EXP_SYSTEM,

			ST_SR_VISIBLE = @SR_VISIBLE,
			ST_SR_COUNT = @SR_COUNT,
			ST_SR_SAVE = @SR_SAVE,

			ST_REP_SAVE	= @REP_SAVE,
			ST_REP_TYPE = @REP_TYPE,
			ST_REP_PATH = @REP_PATH,

			ST_OFFER_PATH = @OFFER_PATH,

			ST_EXCEL_LONG_STRINGS = @EXCEL_LONG,

			ST_FONT_SIZE = @FONT_SIZE,

			ST_CLOSE_QUERY = @CLOSE_QUERY,

			ST_DEBUG = @DEBUG
		WHERE ST_USER = ORIGINAL_LOGIN()
			AND ST_HOST = HOST_NAME()

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.Settings(
				ST_CLIENT, ST_MENU, ST_EXT_SEARCH,

				ST_CA_STATUS, ST_CA_CATEGORY,
				ST_CA_INN, ST_CA_SERVICE,
				ST_CA_ACTIVITY, ST_CA_PAPPER,
				ST_CA_GRAPH,

				ST_EXP_NUM, ST_EXP_NAME, ST_EXP_ADDRESS, ST_EXP_INN,
				ST_EXP_DIR, ST_EXP_BUH, ST_EXP_RES,
				ST_EXP_TYPE, ST_EXP_PERSONAL,
				ST_EXP_BOOK, ST_EXP_PAPPER,
				ST_EXP_STATUS, ST_EXP_SYSTEM,

				ST_REP_SAVE, ST_REP_TYPE, ST_REP_PATH,

				ST_OFFER_PATH, ST_EXCEL_LONG_STRINGS, ST_FONT_SIZE, ST_CLOSE_QUERY,

				ST_DEBUG
				)
			VALUES(
				@CLIENT, @MENU, @EXT_SEARCH,

				@CA_STATUS, @CA_CATEG,
				@CA_INN, @CA_SERVICE,
				@CA_ACTIVITY, @CA_PAPPER,
				@CA_GRAPH,

				@EXP_NUM, @EXP_NAME, @EXP_ADDRESS, @EXP_INN,
				@EXP_DIR, @EXP_BUH, @EXP_RES,
				@EXP_TYPE, @EXP_PERSONAL,
				@EXP_BOOK, @EXP_PAPPER,
				@EXP_STATUS, @EXP_SYSTEM,
				@REP_SAVE, @REP_TYPE, @REP_PATH,

				@OFFER_PATH, @EXCEL_LONG, @FONT_SIZE, @CLOSE_QUERY,

				@DEBUG
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SETTINGS_SAVE] TO public;
GO
