USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Raw].[INCOMES_IMPORT_METADATA_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Raw].[INCOMES_IMPORT_METADATA_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Raw].[INCOMES_IMPORT_METADATA_DELETE]
    @Id             SmallInt
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

        DELETE
        FROM Raw.[Incomes:Import?Metadata]
        WHERE [Id] = @Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[INCOMES_IMPORT_METADATA_DELETE] TO rl_incomes_import_metadata_d;
GO
