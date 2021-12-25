USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_REINDEX]
    @ID     UNIQUEIDENTIFIER    =   NULL,
    @LIST   NVARCHAR(MAX)       =   NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER PRIMARY KEY);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        IF @ID IS NULL AND @LIST IS NULL
            INSERT INTO @TBL
            SELECT ID
            FROM Client.Company
            WHERE STATUS = 1;

        IF @ID IS NOT NULL
            INSERT INTO @TBL(ID)
            SELECT @ID

        IF @LIST IS NOT NULL
            INSERT INTO @TBL(ID)
            SELECT ID
            FROM Common.TableGUIDFromXML(@LIST);

        /*
        UPDATE z
        SET ADDRESS =
                (
                    SELECT TOP 1 AD_STR
                    FROM Client.OfficeAddressMainView WITH(NOEXPAND)
                    WHERE CO_ID = z.ID_COMPANY
                    ORDER BY MAIN DESC, ID
                ),
            EMAILS = Reverse(Stuff(Reverse(
                (
                    SELECT EML.[EMAIL] + ','
                    FROM
                    (
                        SELECT b.[EMAIL]
                        FROM Client.Company b
                        WHERE b.ID = z.ID_COMPANY
                        --
                        UNION
                        --
                        SELECT P.[EMAIL]
                        FROM Client.CompanyPersonal AS P
                        WHERE P.ID_COMPANY = Z.ID_COMPANY
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
                    WHERE cp.ID_COMPANY = t.ID
                    FOR XML PATH('')
            )), 1, 2, '')),
            AVA_COLOR = I.AVA_COLOR,
            SenderIndex = I.SenderIndex,
            DATA = I.[Data]
        FROM @TBL t
        INNER JOIN Client.CompanyIndex z ON T.ID = z.ID_COMPANY
        INNER JOIN [Client].[CompanyIndexView] AS I ON I.ID = z.ID_COMPANY
        OPTION (RECOMPILE);

        INSERT INTO Client.CompanyIndex(ID_COMPANY, ADDRESS, EMAILS, PROJECTS, AVA_COLOR, SenderIndex, [Data])
        SELECT
            Z.ID,
            (
                SELECT TOP 1 AD_STR
                FROM Client.OfficeAddressMainView WITH(NOEXPAND)
                WHERE CO_ID = Z.ID
                ORDER BY MAIN DESC, ID
            ),
            Reverse(Stuff(Reverse(
                (
                    SELECT EML.[EMAIL] + ','
                    FROM
                    (
                        SELECT b.[EMAIL]
                        FROM Client.Company b
                        WHERE b.ID = z.ID
                        --
                        UNION
                        --
                        SELECT P.[EMAIL]
                        FROM Client.CompanyPersonal AS P
                        WHERE P.ID_COMPANY = Z.ID
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
                    WHERE cp.ID_COMPANY = Z.ID
                    FOR XML PATH('')
            )), 1, 2, '')),
            I.AVA_COLOR,
            I.SenderIndex,
            I.[Data]
        FROM @TBL z
        INNER JOIN [Client].[CompanyIndexView] AS I ON I.ID = Z.ID
        WHERE NOT EXISTS
            (
                SELECT *
                FROM Client.CompanyIndex t
                WHERE t.ID_COMPANY = Z.ID
            )
        OPTION (RECOMPILE);
        */
        INSERT INTO Client.CompanyIndexQueue(ID_COMPANY)
        SELECT [ID]
        FROM @TBL;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_REINDEX] TO rl_company_reindex;
GO
