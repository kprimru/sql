USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[GET_OLD_CONTRACT]
	@date SMALLDATETIME,
	@serviceid INT,
	@managerid INT,
	@statusid INT
AS
BEGIN	
	SET NOCOUNT ON;

	/*
	IF @date IS NULL
		SET @date = CONVERT(VARCHAR, GETDATE(), 112)
	*/

	IF @serviceid IS NOT NULL
		SELECT b.ClientID, ClientFullName, MAX(ContractBegin) AS ContractbeginStr, MAX(ContractEnd) AS ContrctEndStr
		FROM 
			dbo.ClientTable b LEFT OUTER JOIN
			dbo.ContractTable a ON a.ClientID = b.ClientID
		WHERE NOT EXISTS 
				(
					SELECT * 
					FROM dbo.ContractTable c 
					WHERE c.ClientID = a.ClientID AND 
						c.ContractBegin <= @date AND 
						c.ContractEnd >= @date
				) 
			AND ClientServiceID = @serviceid 
			AND StatusID = ISNULL(@statusid, StatusID)
			AND STATUS = 1
		GROUP BY b.ClientID, ClientFullName
		ORDER BY ClientFullName
	ELSE IF @managerid IS NOT NULL
		SELECT b.ClientID, ClientFullName, MAX(ContractBegin) AS ContractbeginStr, MAX(ContractEnd) AS ContrctEndStr
		FROM 
			dbo.ClientTable b 
			INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID 
			LEFT OUTER JOIN  dbo.ContractTable a ON a.ClientID = b.ClientID
		WHERE NOT EXISTS 
			(
				SELECT * 
				FROM dbo.ContractTable c 
				WHERE c.ClientID = a.ClientID AND 
					c.ContractBegin <= @date AND 
					c.ContractEnd >= @date
			) 
			AND	ManagerID = @managerid 
			AND StatusID = ISNULL(@statusid, StatusID)
			AND STATUS = 1
		GROUP BY b.ClientID, ClientFullName
		ORDER BY ClientFullName
	ELSE 
		SELECT b.ClientID, ClientFullName, MAX(ContractBegin) AS ContractbeginStr, MAX(ContractEnd) AS ContrctEndStr
		FROM 
			dbo.ClientTable b 
			LEFT OUTER JOIN dbo.ContractTable a ON a.ClientID = b.ClientID
		WHERE NOT EXISTS 
			(
				SELECT * 
				FROM dbo.ContractTable c 
				WHERE c.ClientID = a.ClientID AND 
					c.ContractBegin <= @date AND 
					c.ContractEnd >= @date
			) 
			AND	StatusID = ISNULL(@statusid, StatusID)
			AND STATUS = 1			
		GROUP BY b.ClientID, ClientFullName
		ORDER BY ClientFullName
END