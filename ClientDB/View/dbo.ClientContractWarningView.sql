USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientContractWarningView]
AS
	SELECT ClientID
	FROM dbo.ClientTable a
	INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
	WHERE STATUS = 1
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ContractTable e
				WHERE e.ClientID = a.ClientID
					AND e.ContractEnd >= dbo.DateOf(GETDATE())
			)
		AND NOT EXISTS
			(
				SELECT *
				FROM Contract.ClientContracts CC
				INNER JOIN Contract.Contract C ON C.ID = CC.Contract_Id
				CROSS APPLY
				(
					SELECT TOP (1) ExpireDate
					FROM Contract.ClientContractsDetails D
					WHERE D.Contract_Id = C.ID
					ORDER BY DATE DESC
				) D
				WHERE CC.Client_Id = a.ClientID
					AND C.DateTo IS NULL
					AND D.ExpireDate >= dbo.DateOf(GETDATE())
			)
