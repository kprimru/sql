USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[LOCK_RELEASE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[LOCK_RELEASE]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[LOCK_RELEASE]
	@ID		NVARCHAR(MAX),
	@DATA	VARCHAR(64)
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
		DELETE
		FROM Common.Locks
		WHERE DATA = @DATA
			AND REC IN
				(
					SELECT ID
					FROM Common.TableStringFromXML(@ID)
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
GRANT EXECUTE ON [Common].[LOCK_RELEASE] TO public;
GO
