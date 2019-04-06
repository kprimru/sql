USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SELECT_CONTRACT_FILTER]
	@MANAGER	INT,
	@SERVICE	INT,
	@STATUS		INT,
	@PAY		INT,
	@TYPE		INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ContractID, ClientFullName, ManagerName, ContractEnd AS MaxContractEnd, ContractDate,
		ContractNumber, ServiceStatusName, ContractTypeName, 
		ServiceName, ContractPayName,
		REVERSE(STUFF(REVERSE(
			(
				SELECT SystemShortName + ', '
				FROM 
					(
						SELECT DISTINCT SystemShortName, SystemOrder
						FROM
							dbo.ClientDistrView z WITH(NOEXPAND)							
						WHERE z.ID_CLIENT = a.ClientID AND DS_REG = 0
					) AS o_O
				ORDER BY SystemOrder FOR XML PATH('')
			)
		), 1, 2, '')) AS SystemList
	FROM 
		dbo.ClientReadList()
		INNER JOIN dbo.ContractTable a ON RCL_ID = ClientID 
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID 		
		INNER JOIN dbo.ContractTypeTable e ON a.ContractTypeID = e.ContractTypeID 
		INNER JOIN dbo.ContractPayTable f ON f.ContractPayID = a.ContractPayID		
	WHERE ContractEnd =  
		(
			SELECT Max(z.ContractEnd) AS MaxContractEnd          
			FROM dbo.ContractTable z
			WHERE a.ClientID = z.ClientID
		)
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (ServiceStatusID = @STATUS	OR @STATUS IS NULL)
		AND (f.ContractPayID = @PAY OR @PAY IS NULL)
		AND (e.ContractTypeID = @TYPE OR @TYPE IS NULL)
	ORDER BY ClientFullName, ContractEnd DESC
END