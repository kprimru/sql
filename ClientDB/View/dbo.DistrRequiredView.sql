USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[DistrRequiredView]
WITH SCHEMABINDING
AS
	SELECT
		b.SystemID, DistrNumber, CompNumber, Complect, d.InfoBankID, ID_SYSTEM, 
		SystemOrder, InfoBankShortName, InfoBankOrder, InfoBankStart, InfoBankName,
		SystemActive, InfoBankActive, e.ID_NOT_SYSTEM, [Required]
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.SystemBankTable c ON b.SystemID = c.SystemID
		INNER JOIN dbo.InfoBankTable d ON d.InfoBankID = c.InfoBankID
		INNER JOIN dbo.SystemBankRequired e ON e.ID_SB = c.ID
	WHERE Required IN (2, 3) AND a.Service = 0
