USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Raw].[Income@Load]
    @Organization_Id    SmallInt,
    @FileName           VarChar(256),
    @FileDateTime       DateTime,
    @FileSize           BigInt,
    @Data               Xml,
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
        INSERT INTO [Raw].[Incomes]([FileName], [FileDateTime], [FileSize], [DateTime], [Organization_Id])
        VALUES (@FileName, @FileDateTime, @FileSize, GetDate(), @Organization_Id);

        SELECT @Id = Scope_Identity();

        INSERT INTO [Raw].[Incomes:Details]([Income_Id], [Date], [INN], [Name], [Purpose], [Num], [Price])
        SELECT @Id, [Date], [Inn], [Name], [Purpose], [Num], [Price]
        FROM [Raw].[Income@Parse](@Data);

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[Income@Load] TO rl_income_w;
GO
