USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claim@UnSet Company]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claim@UnSet Company]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[Claim@UnSet Company]
    @Id             Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Company_Id     UniqueIdentifier;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        UPDATE [Client].[Company] SET
            SENDER_NOTE = NULL
        WHERE ID IN (SELECT [Company_Id] FROM [Claim].[Claims:Companies] WHERE [Claim_Id] = @Id);

        DELETE FROM [Claim].[Claims:Companies]
        WHERE [Claim_Id] = @Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        IF @@TranCount > 0
            ROLLBACK TRAN;

        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim@UnSet Company] TO rl_claim_unset_company;
GO
