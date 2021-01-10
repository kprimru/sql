USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC [Claim].[Claims@Appoint]
        @IDs            = '1,2,3,4',
        @Personal_Id    = '625E64E5-7A6A-4BC3-9615-269DD9061065';
*/
ALTER PROCEDURE [Claim].[Claims@Appoint]
    @IDs            VarChar(Max),
    @Personal_Id    UniqueIdentifier
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

    DECLARE
        @Status_Id_APPOINT      TinyInt;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        BEGIN TRAN;

        SET @Status_Id_APPOINT = (SELECT TOP (1) [Id] FROM [Claim].[Claims->Statuses] WHERE [Code] = 'APPOINTED');

        INSERT INTO @ClaimsIDs
        SELECT ID
        FROM [Common].[TableIDFromXML](@IDs);

        INSERT INTO [Claim].[Claims:Statuses]([Claim_Id], [Index], [DateTime], [Status_Id], [Personal_Id])
        SELECT C.[Id], IsNull(S.[Index] + 1, 1), GetDate(), @Status_Id_APPOINT, @Personal_Id
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
            [Status_Id]     = @Status_Id_APPOINT,
            [Personal_Id]   = @Personal_Id
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
GRANT EXECUTE ON [Claim].[Claims@Appoint] TO rl_claim_appoint;
GO