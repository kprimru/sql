USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEMS_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemID, SystemShortName, SystemName, SystemBaseName, SystemNumber, MainInfoBankID, SystemOrder, SystemFullName, SystemActive
	FROM dbo.SystemView
	ORDER BY SystemOrder
END