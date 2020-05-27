USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_REINDEX_QUEUE]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Id             BigInt,
        @Company        UniqueIdentifier;

    WHILE (1 = 1) BEGIN
        SELECT TOP (1)
            @Company    = ID_COMPANY,
            @Id         = Id
        FROM Client.CompanyIndexQueue
        ORDER BY
            [Id] DESC;

        IF @@RowCount < 1 BEGIN
            WAITFOR DELAY '00:00:05';
            CONTINUE;
        END;

        UPDATE z
        SET DATA = I.Data
        FROM Client.CompanyIndex z
        OUTER APPLY
        (
            SELECT TOP (1) [Data] = I.[Data]
            FROM [Client].[CompanyIndexView] AS I
            WHERE I.ID = z.ID_COMPANY
        ) AS I
        WHERE z.ID_COMPANY = @Company;

        DELETE
        FROM Client.CompanyIndexQueue
        WHERE ID_COMPANY = @Company
            AND Id <= @Id;
    END;
END
GO
