USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claim@Get]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claim@Get]  AS SELECT 1')
GO
/*
    EXEC [Claim].[Claim@Get]
        @Id = 1;
*/
ALTER PROCEDURE [Claim].[Claim@Get]
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
            [Type_Id]           = C.[Type_Id],
            [Number]            = C.[Number],
            [CreateDateTime]    = C.[CreateDateTime],
            [FIO]               = C.[FIO],
            [ClientName]        = C.[ClientName],
            [CityName]          = C.[CityName],
            [Email]             = C.[Email],
            [Phone]             = C.[Phone],
            [Special]           = C.[Special],
            [Actions]           = C.[Actions],
            [PageURL]           = C.[PageURL],
            [PageTitle]         = C.[PageTitle],
            [Company_Id]        = C.[Company_Id],
            [CompanyNumber]     = CC.[Number],
            [CompanyName]       = CC.[Name]
        FROM [Claim].[Claims] AS C
        LEFT JOIN [Client].[Company] AS CC ON C.[Company_Id] = CC.[Id]
        WHERE C.[Id] = @Id

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim@Get] TO rl_claim_r;
GO
