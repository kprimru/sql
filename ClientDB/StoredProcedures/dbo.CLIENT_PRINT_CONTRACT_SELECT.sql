USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_PRINT_CONTRACT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_PRINT_CONTRACT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_PRINT_CONTRACT_SELECT]
    @LIST   VarChar(MAX)
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

        DECLARE @Clients Table
        (
            CL_ID Int Primary Key Clustered
        );

        INSERT INTO @Clients
        SELECT [ID]
        FROM [dbo].[TableIDFromXML](@LIST);

        SELECT
            [CL_ID],
            [ContractNumber], [ContractTypeName], [ContractBegin], [ContractDate], [ContractEnd],
            [ContractDiscount], [ContractConditions], [ContractPayName], [ContractYear], [ContractFixed]
        FROM @Clients                       AS CL
        INNER JOIN [dbo].[ClientView] AS CV WITH(NOEXPAND) ON CL.[CL_ID] = CV.[ClientID]
        CROSS APPLY
        (
            SELECT
                [ContractNumber] = C.[NUM_S],
                [ContractTypeName],
                [ContractBegin] = [DateFrom],
                [ContractDate] = [SignDate],
                [ContractEnd] = [ExpireDate],
                [ContractConditions] = D.[Comments],
                [ContractDiscount]  = D.[DiscountValue],
                [ContractPayName],
                [ContractYear] = DatePart(Year, P.[START]),
                [ContractFixed] = [ContractPrice]
            FROM [Contract].[ClientContracts]   AS CC
            INNER JOIN [Contract].[Contract]    AS C ON CC.[Contract_Id] = C.[ID]
            INNER JOIN [Common].[Period]        AS P ON P.[ID] = C.[ID_YEAR]
            CROSS APPLY
            (
                SELECT TOP (1)
                    [ContractTypeName], [ExpireDate], [Comments], [ContractPayName], [ContractPrice], DT.[DiscountValue]
                FROM [Contract].[ClientContractsDetails]    AS D
                INNER JOIN [dbo].[ContractTypeTable]        AS T    ON T.[ContractTypeID] = D.[Type_Id]
                LEFT JOIN [dbo].[ContractPayTable]          AS P    ON P.[ContractPayID] = D.[PayType_Id]
                LEFT JOIN [dbo].[DiscountTable]             AS DT   ON DT.[DiscountID] = D.[Discount_Id]
                WHERE D.[Contract_Id] = CC.[Contract_Id]
                ORDER BY
                    D.[Date] DESC
            ) AS D
            WHERE   CC.[Client_Id] = CL.[CL_ID]
                AND C.[DateFrom] <= GetDate() AND (C.[DateTo] >= GetDate() OR C.[DateTo] IS NULL)
        ) AS D
        WHERE [Maintenance].[GlobalContractOld]() = 0

        UNION ALL

        SELECT
            [CL_ID],
            [ContractNumber], [ContractTypeName], [ContractBegin], [ContractDate], [ContractEnd],
            [ContractDiscount], [ContractConditions], [ContractPayName], [ContractYear], [ContractFixed]
        FROM @Clients                       AS CL
        INNER JOIN [dbo].[ClientView] AS CV WITH(NOEXPAND) ON CL.[CL_ID] = CV.[ClientID]
        CROSS APPLY
        (
            SELECT TOP (1)
                [ContractNumber] = C.[NUM_S],
                [ContractTypeName],
                [ContractBegin] = [DateFrom],
                [ContractDate] = [SignDate],
                [ContractEnd] = [ExpireDate],
                [ContractConditions] = D.[Comments],
                [ContractDiscount]  = D.[DiscountValue],
                [ContractPayName],
                [ContractYear] = DatePart(Year, P.[START]),
                [ContractFixed] = [ContractPrice]
            FROM [Contract].[ClientContracts]   AS CC
            INNER JOIN [Contract].[Contract]    AS C ON CC.[Contract_Id] = C.[ID]
            INNER JOIN [Common].[Period]        AS P ON P.[ID] = C.[ID_YEAR]
            CROSS APPLY
            (
                SELECT TOP (1)
                    [ContractTypeName], [ExpireDate], [Comments], [ContractPayName], [ContractPrice], DT.[DiscountValue]
                FROM [Contract].[ClientContractsDetails]    AS D
                INNER JOIN [dbo].[ContractTypeTable]        AS T ON T.[ContractTypeID] = D.[Type_Id]
                INNER JOIN [dbo].[ContractPayTable]         AS P ON P.[ContractPayID] = D.[PayType_Id]
                LEFT JOIN [dbo].[DiscountTable]             AS DT   ON DT.[DiscountID] = D.[Discount_Id]
                WHERE D.[Contract_Id] = CC.[Contract_Id]
                ORDER BY
                    D.[Date] DESC
            ) AS D
            WHERE   CC.[Client_Id] = CL.[CL_ID]
            ORDER BY [DateFrom] DESC
        ) D
        WHERE NOT EXISTS
            (
                SELECT *
                FROM [Contract].[ClientContracts]   AS CC
                INNER JOIN [Contract].[Contract]    AS C ON CC.[Contract_Id] = C.[ID]
                WHERE   CC.[Client_Id] = CL.[CL_ID]
                    AND C.[DateFrom] <= GetDate() AND (C.[DateTo] >= GetDate() OR C.[DateTo] IS NULL)
            )
            AND [Maintenance].[GlobalContractOld]() = 0

        UNION ALL

        SELECT
            CL_ID,
            ContractNumber, ContractTypeName, ContractBegin, ContractDate, ContractEnd,
            [ContractDiscount], ContractConditions, ContractPayName, ContractYear, ContractFixed
        FROM @Clients AS CL
        CROSS APPLY
        (
            SELECT TOP (1)
                ClientID, ContractNumber, ContractTypeName, ContractBegin, ContractDate, ContractEnd,
                ContractConditions, ContractPayName, ContractYear, ContractFixed, [ContractDiscount] = DiscountValue
            FROM dbo.ContractTable              AS z
            INNER JOIN dbo.ContractTypeTable    AS y ON y.ContractTypeID = z.ContractTypeID
            INNER JOIN dbo.ContractPayTable     AS x ON x.ContractPayID = z.ContractPayID
            LEFT JOIN [dbo].[DiscountTable]     AS DT   ON DT.[DiscountID] = z.[DiscountID]
            WHERE z.ClientID = CL.CL_ID
            ORDER BY ContractBegin DESC
        ) AS T
        WHERE NOT EXISTS
            (
                SELECT *
                FROM Contract.ClientContracts CC
                INNER JOIN Contract.Contract C ON CC.Contract_Id = C.ID
                WHERE   CC.Client_Id = CL.CL_ID
            )
            OR [Maintenance].[GlobalContractOld]() = 1

        ORDER BY CL_ID, ContractBegin

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PRINT_CONTRACT_SELECT] TO rl_client_p;
GO
