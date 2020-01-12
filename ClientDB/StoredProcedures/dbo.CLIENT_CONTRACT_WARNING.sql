USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CONTROL_DATE SMALLDATETIME

	SET @CONTROL_DATE = dbo.DateOf(DATEADD(MONTH, 1, GETDATE()))

	SELECT 
		b.ClientID, ClientFullName, ManagerName, ExpireDate AS ContractEnd
	FROM 
		dbo.ClientWriteList()
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON WCL_ID = b.ClientID
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.ServiceStatusId = s.ServiceStatusId
		--INNER JOIN dbo.ContractTable a ON a.ClientID = b.ClientID
		INNER JOIN Contract.ClientContracts CC ON CC.Client_Id = b.ClientID
		INNER JOIN Contract.Contract C ON C.ID = CC.Contract_Id
		CROSS APPLY
		(
			SELECT TOP (1) ExpireDate
			FROM Contract.ClientContractsDetails D
			WHERE D.Contract_Id = C.ID
			ORDER BY DATE DESC
		) D
	WHERE 
		--ContractEnd <= @CONTROL_DATE
		C.DateTo IS NULL
		AND D.ExpireDate <= @CONTROL_DATE
		/*
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ContractTable e
				WHERE e.ClientID = a.ClientID
					AND e.ContractEnd >= @CONTROL_DATE
			)
		*/
	--GROUP BY b.ClientID, ClientFullName, ManagerName
	
	UNION ALL
	
	SELECT 
		b.ClientID, ClientFullName, ManagerName, MAX(ContractEnd) AS ContractEnd
	FROM 
		dbo.ClientWriteList()
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON WCL_ID = b.ClientID
		INNER JOIN dbo.ContractTable a ON a.ClientID = b.ClientID
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.ServiceStatusId = s.ServiceStatusId
	WHERE ContractEnd <= @CONTROL_DATE
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ContractTable e
				WHERE e.ClientID = a.ClientID
					AND e.ContractEnd >= @CONTROL_DATE
			)
		AND NOT EXISTS
			(
				SELECT *
				FROM Contract.ClientContracts CC
				WHERE CC.Client_Id = b.ClientID
			)
	GROUP BY b.ClientID, ClientFullName, ManagerName
	
	ORDER BY ClientFullName	
END
