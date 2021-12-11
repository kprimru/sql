USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrRequiredDofView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[DistrRequiredDofView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[DistrRequiredDofView]
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

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.DistrRequiredDofView(DistrNumber,CompNumber,SystemID,InfoBankID)] ON [dbo].[DistrRequiredDofView] ([DistrNumber] ASC, [CompNumber] ASC, [SystemID] ASC, [InfoBankID] ASC);
GO
