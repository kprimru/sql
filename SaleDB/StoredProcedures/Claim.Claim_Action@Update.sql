USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC [Claim].[Claim@Get?Actions]
        @Id = 1;
*/
ALTER PROCEDURE [Claim].[Claim:Action@Update]
    @Claim_Id       Int,
    @Index          TinyInt,
    @DateTime       DateTime,
    @Personal_Id    UniqueIdentifier,
    @Note           VarChar(Max),
    @Meeting        Bit,
    @Offer          Bit,
    @Mailing        Bit,
    @Status_Id      TinyInt,
    @Distr          NvarChar(256)
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
        UPDATE [Claim].[Claims:Actions] SET
            [DateTime] = @DateTime,
            [Personal_Id] = @Personal_Id,
            [Note] = @Note,
            [Meeting] = @Meeting,
            [Offer] = @Offer,
            [Mailing] = @Mailing
        WHERE [Claim_Id] = @Claim_Id
            AND [Index] = @Index;

        UPDATE [Claim].[Claims] SET
            [Distr] = @Distr
        WHERE [Id] = @Claim_Id;

        IF (SELECT [Status_Id] FROM [Claim].[Claims] AS C WHERE C.[Id] = @Claim_Id) != @Status_Id BEGIN
            UPDATE [Claim].[Claims] SET
                [Status_Id] = @Status_Id
            WHERE [Id] = @Claim_Id;

            INSERT INTO [Claim].[Claims:Statuses]([Claim_Id], [Index], [DateTime], [Status_Id], [Personal_Id])
            SELECT TOP (1) @Claim_Id, C.[Index] + 1, @DateTime, @Status_Id, @Personal_Id
            FROM [Claim].[Claims:Statuses] AS C
            WHERE C.[Claim_Id] = @Claim_Id
            ORDER BY
                [Index] DESC;
        END;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim:Action@Update] TO rl_claim_action;
GO
