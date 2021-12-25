USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[SystemView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[SystemView]
AS
	SELECT
		SystemID, SystemShortName, SystemName, SystemBaseName,
		SystemNumber, MainInfoBankID, SystemOrder, SystemFullName, SystemActive
	FROM dbo.SystemTable
GO
