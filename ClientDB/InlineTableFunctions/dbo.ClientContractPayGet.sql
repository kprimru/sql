USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ClientContractPayGet]
(
	@ClientId		Int,
	@Date			SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (1) ContractPayName, ContractPayDay, ContractPayMonth
	FROM
	(
		SELECT Ord, ContractPayName, ContractPayDay, ContractPayMonth
		FROM
		(
			SELECT TOP (1)
				1 AS Ord, ContractPayName, ContractPayDay, ContractPayMonth
			FROM dbo.ContractTable z
			INNER JOIN dbo.ContractPayTable y ON z.ContractPayID = y.ContractPayID
			WHERE z.ClientID = @ClientId
				AND (@Date IS NULL OR @Date BETWEEN ContractBegin AND ContractEnd)
			ORDER BY ContractEnd DESC
		) AS A

		UNION ALL

		SELECT Ord, ContractPayName, ContractPayDay, ContractPayMonth
		FROM
		(
			SELECT TOP (1)
				2 AS Ord, ContractPayName, ContractPayDay, ContractPayMonth
			FROM Contract.ClientContracts z
			INNER JOIN Contract.Contract x ON x.Id = z.Contract_Id
			CROSS APPLY
			(
				SELECT TOP (1) PayType_Id
				FROM Contract.ClientContractsDetails w
				WHERE w.Contract_Id = z.Contract_Id
					AND (@Date IS NULL OR DATE < @Date)
			) w
			INNER JOIN dbo.ContractPayTable y ON w.PayType_Id = y.ContractPayID
			WHERE z.Client_Id = @ClientId
				AND (@Date IS NULL OR @Date BETWEEN DateFrom AND DateTo)
			ORDER BY DateTo DESC
		) AS A
	) AS A
	ORDER BY Ord
)
GO
