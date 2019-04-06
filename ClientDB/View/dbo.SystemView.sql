USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SystemView]
AS
	SELECT 
		SystemID, SystemShortName, SystemName, SystemBaseName, 
		SystemNumber, MainInfoBankID, SystemOrder, SystemFullName, SystemActive
	FROM dbo.SystemTable
