USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claim@Get?Actions]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claim@Get?Actions]  AS SELECT 1')
GO
/*
    EXEC [Claim].[Claim@Get?Actions]
        @Id = 1;
*/
ALTER PROCEDURE [Claim].[Claim@Get?Actions]
    @Id         Int     = NULL
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
            [DateTime]      = C.[DateTime],
            [Personal_Id]   = C.[Personal_Id],
            [Note]          = C.[Note],
            [Meeting]       = C.[Meeting],
            [Offer]         = C.[Offer],
            [Mailing]       = C.[Mailing]
        FROM [Claim].[Claims:Actions] AS C
        WHERE C.[Claim_Id] = @Id
        ORDER BY C.[Index] DESC;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim@Get?Actions] TO rl_claim_r;
GO
