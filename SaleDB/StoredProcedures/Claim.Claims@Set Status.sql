USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC [Claim].[Claims@Appoint]
        @IDs            = '1,2,3,4',
        @Statusl_Id     = 1;
*/
ALTER PROCEDURE [Claim].[Claims@Set Status]
    @IDs            VarChar(Max),
    @Status_Id      TinyInt
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @ClaimsIDs Table
    (
        [Id]    Int NOT NULL PRIMARY KEY CLUSTERED
    );

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO @ClaimsIDs
        SELECT ID
        FROM [Common].[TableIDFromXML](@IDs);

        INSERT INTO [Claim].[Claims:Statuses]([Claim_Id], [Index], [DateTime], [Status_Id])
        SELECT C.[Id], IsNull(S.[Index] + 1, 1), GetDate(), @Status_Id
        FROM @ClaimsIDs AS C
        OUTER APPLY
        (
            SELECT TOP (1)
                S.[Index]
            FROM [Claim].[Claims:Statuses] AS S
            WHERE S.[Claim_Id] = C.[Id]
            ORDER BY S.[Index] DESC
        ) AS S;

        UPDATE C SET
            [Status_Id]     = @Status_Id
        FROM @ClaimsIDs AS I
        INNER JOIN [Claim].[Claims] AS C ON I.[Id] = C.[Id];

        IF @@TranCount > 0
            COMMIT TRAN;

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
GRANT EXECUTE ON [Claim].[Claims@Set Status] TO rl_claim_status;
GO
