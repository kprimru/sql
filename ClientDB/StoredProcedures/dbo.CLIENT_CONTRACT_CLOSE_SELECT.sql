USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTRACT_CLOSE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_CLOSE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_CLOSE_SELECT]
    @Manager_Id     SmallInt    = NULL,
    @Service_Id     SmallInt    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Today  SmallDateTime;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        IF @Service_Id IS NOT NULL
            SET @Manager_Id = NULL

        SET @Today = dbo.DateOf(GetDate());

        SELECT
            [Checked]                   = Cast(CASE WHEN NCC.[ID] IS NULL THEN 0 ELSE 1 END AS Bit),
            [ClientID]                  = CL.[ClientID],
            [ClientFullName]            = CL.[ClientFullName],
            [Manager_Id]                = CL.[Manager_Id],
            [Service_Id]                = CL.[Service_Id],
            [ServiceStatusIndex]        = CL.[ServiceStatusIndex],

            [Contract_Id]               = C.[ID],
            [ContractNumber]            = C.[NUM_S],
            [Vendor_Id]                 = C.[ID_VENDOR],
            [DateFrom]                  = C.[DateFrom],
            [ExpireDate]                = D.[ExpireDate],

            [Type_Id]                   = D.[Type_Id],
            [PayType_Id]                = D.[PayType_Id],
            [Discount_Id]               = D.[Discount_Id],

            [NextContractNumber]        = NCC.[NUM_S],
            [NextContractVendor_Id]     = NCC.[ID_VENDOR],
            [NextContractDateFrom]      = NCC.[DateFrom],
            [NextContractExpireDate]    = NCC.[ExpireDate],
            [NextContractDateTo]        = NCC.[DateTo]
        FROM [Contract].[Contract] AS C
        CROSS APPLY
        (
            SELECT TOP (1) *
            FROM [Contract].[ClientContractsDetails] AS D
            WHERE D.[Contract_Id] = C.[ID]
            ORDER BY D.[DATE] DESC
        ) AS D
        CROSS APPLY
        (
            SELECT TOP (1)
                CC.[Client_Id]
            FROM [Contract].[ClientContracts] AS CC
            INNER JOIN [dbo].[ClientTable] AS CL ON CC.[Client_Id] = CL.[ClientId]
            INNER JOIN [dbo].[ServiceStatusTable] AS SS ON CL.[StatusId] = SS.[ServiceStatusId]
            WHERE CC.[Contract_Id] = C.[ID]
            ORDER BY
                CASE SS.[ServiceStatusReg]
                    WHEN 1 THEN 0
                    ELSE 1
                END,
                SS.[ServiceStatusIndex],
                CASE
                    WHEN CL.[ID_HEAD] IS NULL THEN 0
                    ELSE 1
                END,
                CL.[ClientID]
        ) AS CC
        CROSS APPLY
        (
            SELECT TOP (1)
                [ClientID]              = CL.[ClientID],
                [ClientFullName]        = CL.[ClientFullName],
                [ServiceName]           = CL.[ServiceName],
                [Service_Id]            = CL.[ServiceId],
                [ManagerName]           = CL.[ManagerName],
                [Manager_Id]            = CL.[ManagerId],
                [ServiceStatusIndex]    = CL.[ServiceStatusIndex]
            FROM [dbo].[ClientView] AS CL WITH(NOEXPAND)
            WHERE CL.[ClientID] = CC.[Client_Id]
        ) AS CL
        CROSS APPLY
        (
            SELECT TOP (1)
                [ID]            = NCC.[ID],
                [DateFrom]      = NCC.[DateFrom],
                [DateTo]        = NCC.[DateTo],
                [NUM_S]         = NCC.[NUM_S],
                [ExpireDate]    = NCC.[ExpireDate],
                [ID_VENDOR]     = NCC.[ID_VENDOR]
            FROM
            (
                SELECT TOP (1)
                    [ID]            = NC.[ID],
                    [DateFrom]      = NC.[DateFrom],
                    [DateTo]        = NC.[DateTo],
                    [NUM_S]         = NC.[NUM_S],
                    [ExpireDate]    = ND.[ExpireDate],
                    [ID_VENDOR]     = NC.[ID_VENDOR]
                FROM [Contract].[ClientContracts] AS NCC
                INNER JOIN [Contract].[Contract] AS NC ON NCC.[Contract_Id] = NC.[ID]
                CROSS APPLY
                (
                    SELECT TOP (1)
                        ND.[ExpireDate]
                    FROM [Contract].[ClientContractsDetails] AS ND
                    WHERE ND.[Contract_Id] = NC.[ID]
                    ORDER BY ND.[DATE] DESC
                ) AS ND
                WHERE NCC.[Client_Id] = CC.[CLient_Id]
                    AND NCC.[Contract_Id] != C.[ID]
                    -- есть договор, который действует после наступления ExpireDate
                    AND (NC.[DateTo] IS NULL OR NC.[DateTo] > D.[ExpireDate])
                    AND (ND.[ExpireDate] IS NULL OR ND.[ExpireDate] > D.[ExpireDate])

                UNION ALL

                SELECT TOP (1)
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL

                ORDER BY
                    CASE WHEN [DateTo] IS NULL THEN 0 ELSE 1 END,
                    [DateTo] DESC,
                    [ExpireDate] DESC
            ) AS NCC
            ORDER BY
                CASE
                    WHEN NCC.[ID] IS NOT NULL THEN 0
                    ELSE 1
                END
        ) AS NCC
        WHERE C.[DateTo] IS NULL
            AND D.[ExpireDate] < @Today
            AND (@Manager_Id IS NULL OR CL.[Manager_Id] = @Manager_Id)
            AND (@Service_Id IS NULL OR CL.[Service_Id] = @Service_Id)
        ORDER BY
            CL.[ManagerName],
            CL.[ServiceName],
            CL.[ClientFullName];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_CLOSE_SELECT] TO rl_client_contract_u;
GO
