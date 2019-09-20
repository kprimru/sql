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
		b.SystemID, DistrNumber, CompNumber, Complect, d.InfoBankID,
		SystemOrder, InfoBankShortName, InfoBankOrder, InfoBankStart, InfoBankName,
		SystemActive, InfoBankActive, RuleNumber = 1
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.InfoBankTable d ON d.InfoBankName = 'DOF'
	WHERE a.Service = 0 AND b.SystemBaseName IN ('LAW', 'ROS')
