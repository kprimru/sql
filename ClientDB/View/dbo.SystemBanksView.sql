USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[SystemBanksView]
WITH SCHEMABINDING
AS
	SELECT 
		c.InfoBankID, InfoBankName, InfoBankShortName, InfoBankFullName,
		InfoBankOrder, InfoBankPath, InfoBankActive,
		a.SystemID, SystemFullName, SystemActive, SystemOrder,
		SystemShortName, SystemBaseName, [Required], HostID,
		InfoBankStart
	FROM
		dbo.SystemTable a INNER JOIN
		dbo.SystemBankTable b ON a.SystemID = b.SystemID INNER JOIN
		dbo.InfoBankTable c ON c.InfoBankID = b.InfoBankID
