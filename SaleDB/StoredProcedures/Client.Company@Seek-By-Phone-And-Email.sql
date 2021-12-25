USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[Company@Seek-By-Phone-And-Email]
    @PHONE      VarChar(100),
    @EMAIL      VarChar(100)
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

        SELECT

            [Id]        = C.[ID],
            [Name]      = C.[NAME],
            [Number]    = C.[NUMBER]
        FROM
        (
            SELECT ID_COMPANY
            FROM Client.CompanyPhone AS P
            WHERE P.STATUS = 1
                AND
                (
                        P.PHONE_S = @PHONE
                )

            UNION

            SELECT ID_COMPANY
            FROM Client.CompanyPersonalPhone AS PP
            INNER JOIN Client.CompanyPersonal AS P ON PP.ID_PERSONAL = P.ID
            WHERE   P.STATUS = 1
                AND PP.STATUS = 1
                AND
                (
                        PP.PHONE_S = @PHONE
                )

            UNION

            SELECT ID_COMPANY
            FROM Client.CompanyPersonal AS P
            WHERE P.STATUS = 1
                AND P.EMAIL = @EMAIL

            UNION

            SELECT ID
            FROM Client.Company AS P
            WHERE P.STATUS = 1
                AND P.EMAIL = @EMAIL
        ) AS P
        INNER JOIN Client.Company AS C ON P.ID_COMPANY = C.ID
        WHERE C.STATUS = 1
        ORDER BY C.NAME;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
