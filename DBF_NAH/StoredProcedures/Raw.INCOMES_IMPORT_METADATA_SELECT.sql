USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Raw].[INCOMES_IMPORT_METADATA_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Raw].[INCOMES_IMPORT_METADATA_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Raw].[INCOMES_IMPORT_METADATA_SELECT]
    @Active             Bit = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SELECT [Id], [Code], [Caption]
        FROM Raw.[Incomes:Import?Metadata]
        WHERE [IsActive] = IsNull(@Active, [IsActive])
        ORDER BY [Code];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[INCOMES_IMPORT_METADATA_SELECT] TO rl_incomes_import_metadata_r;
GO
