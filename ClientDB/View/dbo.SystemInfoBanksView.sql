USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.SystemInfoBanksView
AS
SELECT     dbo.SystemsBanks.System_Id, dbo.SystemTable.SystemBaseName, dbo.SystemsBanks.DistrType_Id, dbo.DistrTypeTable.DistrTypeName, 
                      dbo.SystemsBanks.InfoBank_Id, dbo.InfoBankTable.InfoBankName, dbo.SystemsBanks.Required, dbo.SystemsBanks.Start
FROM         dbo.SystemsBanks INNER JOIN
                      dbo.SystemTable ON dbo.SystemsBanks.System_Id = dbo.SystemTable.SystemID INNER JOIN
                      dbo.DistrTypeTable ON dbo.SystemsBanks.DistrType_Id = dbo.DistrTypeTable.DistrTypeID INNER JOIN
                      dbo.InfoBankTable ON dbo.SystemsBanks.InfoBank_Id = dbo.InfoBankTable.InfoBankID
