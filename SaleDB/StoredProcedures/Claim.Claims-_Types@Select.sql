USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claims->Types@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claims->Types@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[Claims->Types@Select]
    @RC     Int = NULL OUTPUT
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
        SELECT  [Id], [Code], [Name]
        FROM    [Claim].[Claims->Types]
        ORDER BY [Name];

        SET @RC = @@RowCount;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claims->Types@Select] TO rl_claim_type_r;
GO
