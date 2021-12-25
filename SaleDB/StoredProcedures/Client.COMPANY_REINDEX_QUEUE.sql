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
        SET DATA = I.Data,
            ADDRESS =
                (
                    SELECT TOP 1 AD_STR
                    FROM Client.OfficeAddressMainView WITH(NOEXPAND)
                    WHERE CO_ID = @Company
                    ORDER BY MAIN DESC, ID
                ),
            EMAILS = Reverse(Stuff(Reverse(
                (
                    SELECT EML.[EMAIL] + ','
                    FROM
                    (
                        SELECT b.[EMAIL]
                        FROM Client.Company b
                        WHERE b.ID = @Company
                        --
                        UNION
                        --
                        SELECT P.[EMAIL]
                        FROM Client.CompanyPersonal AS P
                        WHERE P.ID_COMPANY = @Company
                    ) AS EML
                    WHERE EML.[EMAIL] IS NOT NULL
                        AND EML.[EMAIL] NOT IN ('', '-')
                    FOR XML PATH('')
                )), 1, 1, '')),
            PROJECTS = REVERSE(STUFF(REVERSE(
                (
                    SELECT y.NAME + ', '
                    FROM Client.CompanyProject cp
                    INNER JOIN Client.Project y ON cp.ID_PROJECT = y.ID
                    WHERE cp.ID_COMPANY = @Company
                    FOR XML PATH('')
            )), 1, 2, '')),
            AVA_COLOR = I.AVA_COLOR,
            SenderIndex = I.SenderIndex
        FROM Client.CompanyIndex z
        OUTER APPLY
        (
            SELECT TOP (1)
                [Data]      = I.[Data],
                [AVA_COLOR] = I.[AVA_COLOR],
                [SenderIndex]   = I.[SenderIndex]
            FROM [Client].[CompanyIndexView] AS I
            WHERE I.ID = z.ID_COMPANY
        ) AS I
        WHERE z.ID_COMPANY = @Company;

        IF @@RowCount = 0
            INSERT INTO Client.CompanyIndex(ID_COMPANY, ADDRESS, EMAILS, PROJECTS, AVA_COLOR, SenderIndex, [Data])
            SELECT
                @Company,
                (
                    SELECT TOP 1 AD_STR
                    FROM Client.OfficeAddressMainView WITH(NOEXPAND)
                    WHERE CO_ID = @Company
                    ORDER BY MAIN DESC, ID
                ),
                Reverse(Stuff(Reverse(
                    (
                        SELECT EML.[EMAIL] + ','
                        FROM
                        (
                            SELECT b.[EMAIL]
                            FROM Client.Company b
                            WHERE b.ID = @Company
                            --
                            UNION
                            --
                            SELECT P.[EMAIL]
                            FROM Client.CompanyPersonal AS P
                            WHERE P.ID_COMPANY = @Company
                        ) AS EML
                        WHERE EML.[EMAIL] IS NOT NULL
                            AND EML.[EMAIL] NOT IN ('', '-')
                        FOR XML PATH('')
                    )), 1, 1, '')),
                REVERSE(STUFF(REVERSE(
                    (
                        SELECT y.NAME + ', '
                        FROM Client.CompanyProject cp
                        INNER JOIN Client.Project y ON cp.ID_PROJECT = y.ID
                        WHERE cp.ID_COMPANY = @Company
                        FOR XML PATH('')
                )), 1, 2, '')),
                I.AVA_COLOR,
                I.SenderIndex,
                I.[Data]
            FROM [Client].[CompanyIndexView] AS I
            WHERE I.[ID] = @Company
                AND NOT EXISTS
                (
                    SELECT *
                    FROM Client.CompanyIndex t
                    WHERE t.ID_COMPANY = @Company
                );

        DELETE
        FROM Client.CompanyIndexQueue
        WHERE ID_COMPANY = @Company
            AND Id <= @Id;
    END;
END
GO
