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
ALTER PROCEDURE [Claim].[Claim:Action@Insert]
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
        SET @Index = (SELECT TOP (1) A.[Index] FROM [Claim].[Claims:Actions] AS A WHERE A.[Claim_Id] = @Claim_Id ORDER BY [Index] DESC);

        IF @Index IS NULL
            SET @Index = 1
        ELSE
            SET @Index = @Index + 1;

        INSERT INTO [Claim].[Claims:Actions]([Claim_Id], [Index], [DateTime], [Personal_Id], [Note], [Meeting], [Offer], [Mailing])
        VALUES(@Claim_Id, @Index, @DateTime, @Personal_Id, @Note, @Meeting, @offer, @Mailing);

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
GRANT EXECUTE ON [Claim].[Claim:Action@Insert] TO rl_claim_action;
GO