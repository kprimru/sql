USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@StageToDepo]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Status_ACCEPT      SmallInt,
        @Status_STAGE       SmallInt,
        @CurNumber          Int;

    BEGIN TRY

        BEGIN TRAN;

        SET @Status_STAGE   = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');
        SET @Status_ACCEPT   = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'ACCEPT');

        INSERT INTO Client.CompanyDepo(
            [Master_Id], [Company_Id], [DateFrom], [DateTo], [Number], [ExpireDate], [Status_Id],
            [Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address],
            [Depo:Person1FIO], [Depo:Person1Phone], [Depo:Person2FIO], [Depo:Person2Phone],
            [Depo:Person3FIO], [Depo:Person3Phone], [Depo:Rival], [SortIndex], [Status], [UpdDate], [UpdUser])
        SELECT
            D.[Id], D.[Company_Id], D.[DateFrom], D.[DateTo], D.[Number], D.[ExpireDate], D.[Status_Id],
            D.[Depo:Name], D.[Depo:Inn], D.[Depo:Region], D.[Depo:City], D.[Depo:Address],
            D.[Depo:Person1FIO], D.[Depo:Person1Phone], D.[Depo:Person2FIO], D.[Depo:Person2Phone],
            D.[Depo:Person3FIO], D.[Depo:Person3Phone], D.[Depo:Rival], D.[SortIndex], 2, GetDate(), Original_Login()
        FROM Client.CompanyDepo AS D
        WHERE [Status] = 1
            AND [Status_Id] IN (@Status_STAGE);

        SELECT @CurNumber = [Number ] FROM Client.[Depo@Get Number]();

        UPDATE D
        SET [Status_Id]     = @Status_ACCEPT,
            [Number]        = @CurNumber + N.[RN] - 1,
            [UpdDate]       = GetDate(),
            [UpdUser]       = Original_Login()
        FROM Client.CompanyDepo AS D
        INNER JOIN
        (
            SELECT N.[Id], RN = Row_Number() Over(ORDER BY N.[SortIndex])
            FROM Client.CompanyDepo AS N
            WHERE [Status] = 1
                AND [Status_Id] IN (@Status_STAGE)
        ) AS N ON D.[Id] = N.[Id];

        IF @@TranCount > 0
            COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TranCount > 0
            ROLLBACK TRAN;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[CompanyDepo@StageToDepo] TO rl_depo_stage_filter;
GO