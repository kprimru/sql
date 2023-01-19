USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[System].[CATEGORY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [System].[CATEGORY_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [System].[CATEGORY_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64)
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
		UPDATE	System.Category
		SET		NAME	=	@NAME,
				SHORT	=	@SHORT,
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
GRANT EXECUTE ON [System].[CATEGORY_UPDATE] TO rl_sys_category_w;
GO
