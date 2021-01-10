USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC [Claim].[Claim@Get?Statuses]
        @Id = 1;
*/
ALTER PROCEDURE [Claim].[Claim@Get?Statuses]
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
            [Status_Id]     = C.[Status_Id],
            [Personal_Id]   = C.[Personal_Id]
        FROM [Claim].[Claims:Statuses] AS C
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
GRANT EXECUTE ON [Claim].[Claim@Get?Statuses] TO rl_claim_r;
GO