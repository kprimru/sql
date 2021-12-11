USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC [Claim].[Claims@Select]
        @FioOrClient = 'Валерия'
*/
ALTER PROCEDURE [Claim].[Claims@Select]
    @Personal_Id    UniqueIdentifier    = NULL,
    @DateFrom       SmallDateTime       = NULL,
    @DateTo         SmallDateTime       = NULL,
    @Statuses       NVarChar(MAX)       = NULL,
    @Types          NVarChar(MAX)       = NULL,
    @Meeting        SmallInt            = NULL,
    @Offer          SmallInt            = NULL,
    @Mailing        SmallInt            = NULL,
    @Number         Int                 = NULL,
    @Specials       NVarChar(MAX)       = NULL,
    @FioOrClient    NVarChar(128)       = NULL,
    @Phone          NVarChar(128)       = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @StatusesIDs Table
    (
        [Id]    TinyInt NOT NULL PRIMARY KEY CLUSTERED
    );

    DECLARE @TypesIDs Table
    (
        [Id]    TinyInt NOT NULL PRIMARY KEY CLUSTERED
    );

    DECLARE @SpecialsIDs Table
    (
        [Id]    VarChar(256) NOT NULL PRIMARY KEY CLUSTERED
    );

    DECLARE
        @Status_Id_DELIVERY     TinyInt;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        SET @Status_Id_DELIVERY = (SELECT TOP (1) [Id] FROM [Claim].[Claims->Statuses] WHERE [Code] = 'DELIVERY');

        SET @DateTo = DateAdd(Day, 1, @DateTo);
        SET @FioOrClient = '%' + NullIf(@FioOrClient, '') + '%';
        SET @Phone = '%' + NullIf(@Phone, '') + '%';

        IF @Types IS NOT NULL
            INSERT INTO @TypesIDs
            SELECT ID
            FROM [Common].[TableIDFromXML](@Types);

        IF @Statuses IS NOT NULL
            INSERT INTO @StatusesIDs
            SELECT ID
            FROM [Common].[TableIDFromXML](@Statuses);

        IF @Specials IS NOT NULL
            INSERT INTO @SpecialsIDs
            SELECT ID
            FROM [Common].[TableStringFromXML](@Specials);

        SELECT
            [Id]                = C.[Id],
            [Type_Id]           = C.[Type_Id],
            [Number]            = C.[Number],
            [CreateDateTime]    = C.[CreateDateTime],
            [FIO]               = C.[FIO],
            [ClientName]        = C.[ClientName],
            [CityName]          = C.[CityName],
            [EMail]             = C.[EMail],
            [Phone]             = C.[Phone],
            [Status_Id]         = C.[Status_Id],
            [WorkDateTime]      = CA.[WorkDateTime],
            [WorkNote]          = CA.[WorkNote],
            [Distr]             = C.[Distr],
            [Personal_Id]       = C.[Personal_Id],
            [Special]           = C.[Special],
            [Actions]           = C.[Actions],
            [PageURL]           = C.[PageURL],
            [PageTitle]         = C.[PageTitle],
            [Company_Id]        = Reverse(Stuff(Reverse((SELECT '{' + Convert(VarChar(100), CO.[ID]) + '}' + ',' FROM [Claim].[Claims:Companies] AS CC INNER JOIN [Client].[Company]   AS CO ON CC.[Company_Id] = CO.[ID] WHERE CC.[Claim_Id] = C.[Id] ORDER BY CO.[Number], CO.[ID] FOR XML PATH(''))), 1, 1, '')),
            [CompanyNumber]     = Reverse(Stuff(Reverse((SELECT Convert(VarChar(100), CO.[Number]) + ',' FROM [Claim].[Claims:Companies] AS CC INNER JOIN [Client].[Company]   AS CO ON CC.[Company_Id] = CO.[ID] WHERE CC.[Claim_Id] = C.[Id] ORDER BY CO.[Number], CO.[ID] FOR XML PATH(''))), 1, 1, '')),
            [DeliveryDate]      = CS.[DeliveryDate],
            [ClaimIndex]        = CA.[ClaimIndex],
            [Meeting]           = CA.[Meeting],
            [Offer]             = CA.[Offer],
            [Mailing]           = CA.[Mailing],
            [Color]             = CCS.[Color]
        FROM [Claim].[Claims] AS C
        INNER JOIN [Claim].[Claims->Statuses] AS CCS ON C.[Status_Id] = CCS.[Id]
        --LEFT JOIN [Client].[Company] AS CC ON C.[Company_Id] = CC.[ID]
        LEFT JOIN @StatusesIDs AS S ON C.[Status_Id] = S.[Id]
        LEFT JOIN @TypesIDs AS T ON C.[Type_Id] = T.[Id]
        LEFT JOIN @SpecialsIDs AS SP ON C.[Special] = SP.[Id]
        OUTER APPLY
        (
            SELECT TOP (1)
                [ClaimIndex]    = CA.[Index],
                [WorkDateTime]  = CA.[DateTime],
                [WorkNote]      = CA.[Note],
                [Meeting]       = [Common].[BitToStr](CA.[Meeting]),
                [Offer]         = [Common].[BitToStr](CA.[Offer]),
                [Mailing]       = [Common].[BitToStr](CA.[Mailing])
            FROM [Claim].[Claims:Actions] AS CA
            WHERE CA.[Claim_Id] = C.[Id]
            ORDER BY
                CA.[Index] DESC
        ) AS CA
        OUTER APPLY
        (
            SELECT TOP (1)
                [DeliveryDate] = CS.[DateTime]
            FROM [Claim].[Claims:Statuses] AS CS
            WHERE CS.[Claim_Id] = C.[Id]
                AND CS.[Status_Id] = @Status_Id_DELIVERY
            ORDER BY CS.[DateTime]
        ) AS CS
        WHERE
                (C.[Number] = @Number OR @Number IS NULL)
            AND (C.[CreateDateTime] >= @DateFrom OR @DateFrom IS NULL)
            AND (C.[CreateDateTime] < @DateTo OR @DateTo IS NULL)
            AND (S.[Id] IS NOT NULL OR @Statuses IS NULL)
            AND (T.[Id] IS NOT NULL OR @Types IS NULL)
            AND (SP.[Id] IS NOT NULL OR @Specials IS NULL)
            AND (C.[Personal_Id] = @Personal_Id OR @Personal_Id IS NULL)
            AND (@Meeting IS NULL OR @Meeting = -1 OR @Meeting = 0 OR @Meeting = 1 AND Meeting = 1 OR @Meeting = 2 AND Meeting = 0)
            AND (@Offer IS NULL OR @Offer = -1 OR @Offer = 0 OR @Offer = 1 AND Offer = 1 OR @Offer = 2 AND Offer = 0)
            AND (@Mailing IS NULL OR @Mailing = -1 OR @Mailing = 0 OR @Mailing = 1 AND Mailing = 1 OR @Mailing = 2 AND Mailing = 0)
            AND (C.[FIO] LIKE @FioOrClient OR C.[ClientName] LIKE @FioOrClient OR @FioOrClient IS NULL)
            AND (C.[Phone]LIKE @Phone OR @Phone IS NULL)
        ORDER BY C.[CreateDateTime] DESC, C.[Number];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claims@Select] TO rl_claim_r;
GO
