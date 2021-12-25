USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientContractPayGet]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[ClientContractPayGet] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [dbo].[ClientContractPayGet]
(
    @ClientId       Int,
    @Date           SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        C.[ContractPayName],
        C.[ContractPayDay],
        C.[ContractPayMonth]
    FROM
    (
        SELECT [Ord], [ContractPayName], [ContractPayDay], [ContractPayMonth]
        FROM
        (
            SELECT TOP (1)
                [Ord]               = 2,
                [ContractPayName]   = CP.[ContractPayName],
                [ContractPayDay]    = CP.[ContractPayDay],
                [ContractPayMonth]  = CP.[ContractPayMonth]
            FROM [dbo].[ContractTable]          AS C
            INNER JOIN [dbo].[ContractPayTable] AS CP ON C.[ContractPayID] = CP.[ContractPayID]
            WHERE   C.[ClientID] = @ClientId
                AND (@Date IS NULL OR (@Date >= C.[ContractBegin] AND (@Date <= C.[ContractEnd] OR C.[ContractEnd] IS NULL)))
            ORDER BY C.[ContractEnd] DESC
        ) AS C

        UNION ALL

        SELECT [Ord], [ContractPayName], [ContractPayDay], [ContractPayMonth]
        FROM
        (
            SELECT TOP (1)
                [Ord]               = 1,
                [ContractPayName]   = CP.[ContractPayName],
                [ContractPayDay]    = CP.[ContractPayDay],
                [ContractPayMonth]  = CP.[ContractPayMonth]
            FROM [Contract].[ClientContracts]   AS CC
            INNER JOIN [Contract].[Contract]    AS C ON C.[Id] = CC.[Contract_Id]
            CROSS APPLY
            (
                SELECT TOP (1)
                    [PayType_Id] = CCD.[PayType_Id]
                FROM [Contract].[ClientContractsDetails] AS CCD
                WHERE CCD.[Contract_Id] = CC.[Contract_Id]
                    AND (@Date IS NULL OR CCD.[DATE] < @Date)
                ORDER BY CCD.[Date] DESC
            ) AS CCD
            INNER JOIN [dbo].[ContractPayTable] AS CP ON CCD.[PayType_Id] = CP.[ContractPayID]
            WHERE   CC.[Client_Id] = @ClientId
                AND (@Date IS NULL OR (@Date >= C.[DateFrom] AND (@Date <= C.[DateTo] OR C.[DateTo] IS NULL)))
            ORDER BY
                CASE WHEN C.[DateTo] IS NULL THEN 1 ELSE 2 END,
                C.[DateTo] DESC
        ) AS C
        WHERE [Maintenance].[GlobalContractOld]() = 0
    ) AS C
    ORDER BY
        C.[Ord]
);
GO
