USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[ClientContractWarningView]
AS
	SELECT ClientID
	FROM 
		dbo.ClientTable a
	WHERE STATUS = 1
		AND StatusID = 2
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ContractTable e
				WHERE e.ClientID = a.ClientID
					AND e.ContractEnd >= dbo.DateOf(GETDATE())
			)