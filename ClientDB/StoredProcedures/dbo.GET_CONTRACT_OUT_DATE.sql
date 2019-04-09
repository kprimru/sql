USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- получение просроченных договоров

CREATE PROCEDURE [dbo].[GET_CONTRACT_OUT_DATE] 
	@curdate VARCHAR(20),
	@managerid INT = NULL,
	@statusid INT = 2
AS
BEGIN
	SET NOCOUNT ON

	IF @managerid IS NULL
		SELECT ClientTable.ClientID, ClientFullName, 
		   Max(ContractBegin) AS ContractBeginStr,
		   Max(ContractEnd) AS ContractEndStr, ServiceName
		FROM dbo.ContractTable LEFT OUTER JOIN
				   dbo.ClientTable ON ClientTable.ClientID = ContractTable.ClientID LEFT OUTER JOIN
				   dbo.ServiceTable ON ClientTable.ClientServiceID = ServiceTable.ServiceID
		WHERE NOT EXISTS(SELECT ContractNumber FROM dbo.ContractTable WHERE (ContractBegin <= @curdate AND ContractEnd >= @curdate) AND ContractTable.CLientID = ClientTable.ClientID) AND StatusID = @statusid AND STATUS = 1
		GROUP BY ClientTable.ClientID, CLientFullName, ServiceName
		ORDER BY ServiceName, ClientFullName
	ELSE
	BEGIN
		DECLARE @t TABLE (Item INT)

		IF (@managerid = 19) OR (@managerid = 11)
			INSERT INTO @t
				SELECT 19 AS Item
				UNION 
				SELECT 11 AS Item
		ELSE
			INSERT INTO @t
				SELECT @managerid AS Item
		

		SELECT ClientTable.ClientID, ClientFullName, 
		   Max(ContractBegin) AS ContractBeginStr,
		   Max(ContractEnd) AS ContractEndStr, ServiceName
		FROM dbo.ContractTable LEFT OUTER JOIN
				   dbo.ClientTable ON ClientTable.ClientID = ContractTable.ClientID LEFT OUTER JOIN
				   dbo.ServiceTable ON ClientTable.ClientServiceID = ServiceTable.ServiceID
		WHERE NOT EXISTS(SELECT ContractNumber FROM dbo.ContractTable WHERE (ContractBegin <= @curdate AND ContractEnd >= @curdate) AND ContractTable.CLientID = ClientTable.ClientID) 
			AND ManagerID IN
				(	
					SELECT Item
					FROM @t
				)			
			AND StatusID = @statusid
			AND STATUS = 1
		GROUP BY ClientTable.ClientID, CLientFullName, ServiceName
		ORDER BY ServiceName, ClientFullName
	END
END