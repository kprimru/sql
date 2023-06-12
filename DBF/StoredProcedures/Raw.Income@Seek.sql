USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Raw].[Income@Seek]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Raw].[Income@Seek]  AS SELECT 1')
GO
ALTER PROCEDURE [Raw].[Income@Seek]
    @Organization_Id    SmallInt,
    @FileName           VarChar(256),
    @FileDateTime       DateTime,
    @FileSize           BigInt,
    @Id                 Int = NULL OUTPUT
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
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        SELECT TOP (1)
            @Id = I.[Id]
        FROM [Raw].[Incomes] AS I
        WHERE   I.[FileName] = @FileName
            AND I.[FileDateTime] = @FileDateTime
            AND I.[FileSize] = @FileSize
            AND I.[Organization_Id] = @Organization_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[Income@Seek] TO rl_income_w;
GO
