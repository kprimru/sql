USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Set Number]
    @Id     UniqueIdentifier,
    @Number Int
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
        @DebugContext   = @DebugContext OUT

    BEGIN TRY
        IF EXISTS(SELECT * FROM Client.CompanyDepo WHERE [Number] = @Number AND [Status] = 1 AND [Id] != @Id)
            RaisError('Ошибка! Данный номер уже используется!', 16, 1);

        UPDATE Client.CompanyDepo
        SET [Number] = @Number
        WHERE [Id] = @Id
    END TRY
    BEGIN CATCH
        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyDepo@Set Number] TO rl_depo_number;
GO
