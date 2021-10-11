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
ALTER PROCEDURE [Claim].[Claim:Action@Get]
    @Claim_Id       Int,
    @Index          TinyInt
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
            A.[DateTime], A.[Personal_Id], A.[Note], A.[Meeting], A.[Offer], A.[Mailing],
            C.[Distr], C.[Status_Id]
        FROM [Claim].[Claims:Actions] AS A
        INNER JOIN [Claim].[Claims] AS C ON A.[Claim_Id] = C.[Id]
        WHERE A.[Claim_Id] = @Claim_Id
            AND A.[Index]  = @Index

        UNION ALL

        SELECT
            GetDate(), NULL, '', A.[Meeting], A.[Offer], A.[Mailing],
            C.[Distr], C.[Status_Id]
        FROM [Claim].[Claims] AS C
        OUTER APPLY
        (
            SELECT TOP (1) *
            FROM [Claim].[Claims:Actions] AS A
            WHERE A.[Claim_Id] = C.[Id]
            ORDER BY A.[Index] DESC
        ) AS A
        WHERE C.[Id] = @Claim_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim:Action@Get] TO rl_claim_action;
GO
