USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Sale].[SALE_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Sale].[SALE_TYPE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Sale].[SALE_TYPE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(256)
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
		UPDATE	Sale.SaleType
		SET		NAME	=	@NAME,
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
GRANT EXECUTE ON [Sale].[SALE_TYPE_UPDATE] TO rl_sale_type_w;
GO
