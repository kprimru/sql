USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DistrRequiredQsovView]
WITH SCHEMABINDING
AS
	SELECT
		b.SystemID, DistrNumber, CompNumber, Complect, d.InfoBankID,
		SystemOrder, InfoBankShortName, InfoBankOrder, InfoBankStart, InfoBankName,
		SystemActive, InfoBankActive, RuleNumber = 2
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.InfoBankTable d ON d.InfoBankName = 'QSOV'
	WHERE a.Service = 0 AND b.SystemBaseName IN ('LAW', 'JUR', 'BUD', 'BUDU', 'JURP')
