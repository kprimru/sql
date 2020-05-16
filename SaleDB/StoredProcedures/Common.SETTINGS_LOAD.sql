USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[SETTINGS_LOAD]
	@ID_USER		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		IF EXISTS
			(
				SELECT *
				FROM Common.Settings
				WHERE ID_USER = @ID_USER
			)
			SELECT	DEFAULT_RUS, SEARCH_EXT, MULTY_SEARCH, WARNING_TIME, FONT_SIZE, OFFER_PATH,
					(SELECT VALUE FROM Common.GlobalSettings WHERE NAME = N'AUTH') AS AUTH
			FROM	Common.Settings
			WHERE	ID_USER		=	@ID_USER
		ELSE
			SELECT	DEFAULT_RUS, SEARCH_EXT, MULTY_SEARCH, WARNING_TIME, FONT_SIZE, OFFER_PATH,
					(SELECT VALUE FROM Common.GlobalSettings WHERE NAME = N'AUTH') AS AUTH
			FROM	Common.Settings
			WHERE	ID_USER IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Common].[SETTINGS_LOAD] TO public;
GO