USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Address].[CITY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Address].[CITY_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Address].[CITY_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(256),
	@PREFIX	NVARCHAR(256),
	@PHONE	NVARCHAR(32),
	@DISP	BIT
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
		UPDATE	Address.City
		SET		NAME	=	@NAME,
				PREFIX	=	@PREFIX,
				PHONE	=	@PHONE,
				DISPLAY	=	@DISP,
				LAST	=	GETDATE()
		WHERE	ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Address].[CITY_UPDATE] TO rl_city_w;
GO
