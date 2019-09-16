USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SystemInfoBanksView]
WITH SCHEMABINDING 
AS
	SELECT
		SB.System_Id, S.SystemBaseName, S.SystemOrder, S.SystemActive, S.SystemFullName, S.SystemShortName,
		SB.DistrType_Id, D.DistrTypeName,
		SB.InfoBank_Id, I.InfoBankName, I.InfoBankShortName, I.InfoBankFullName, I.InfoBankOrder, I.InfoBankPath, I.InfoBankActive, I.InfoBankStart,
		SB.Required, SB.Start,
		S.HostId
	FROM dbo.SystemsBanks SB
	INNER JOIN dbo.SystemTable S ON SB.System_Id = S.SystemID
	INNER JOIN dbo.DistrTypeTable D ON SB.DistrType_Id = D.DistrTypeID
	INNER JOIN dbo.InfoBankTable I ON SB.InfoBank_Id = I.InfoBankID
