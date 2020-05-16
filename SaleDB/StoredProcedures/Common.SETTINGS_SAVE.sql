USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[SETTINGS_SAVE]
	@ID_USER		UNIQUEIDENTIFIER,
	@DEFAULT_RUS	BIT,
	@SEARCH_EXT		BIT,
	@MULTY_SEARCH	BIT,
	@WARNING_TIME	SMALLINT = 60,
	@FONT_SIZE		SMALLINT = 8,
	@OFFER_PATH		NVARCHAR(512) = NULL
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
		IF @ID_USER IS NOT NULL
		BEGIN
			UPDATE	Common.Settings
			SET		DEFAULT_RUS		=	@DEFAULT_RUS,
					SEARCH_EXT		=	@SEARCH_EXT,
					MULTY_SEARCH	=	@MULTY_SEARCH,
					WARNING_TIME	=	@WARNING_TIME,
					FONT_SIZE		=	@FONT_SIZE,
					OFFER_PATH		=	@OFFER_PATH,
					LAST			=	GETDATE()
			WHERE ID_USER = @ID_USER

			IF @@ROWCOUNT = 0
				INSERT INTO Common.Settings(ID_USER, DEFAULT_RUS, SEARCH_EXT, WARNING_TIME, FONT_SIZE, OFFER_PATH)
					VALUES(@ID_USER, @DEFAULT_RUS, @SEARCH_EXT, @WARNING_TIME, @FONT_SIZE, @OFFER_PATH)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Common].[SETTINGS_SAVE] TO public;
GO