USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_SELECT_ORDER]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.SystemID, SystemShortName, SystemOrder,
		(
			SELECT COUNT(*)
			FROM dbo.SystemTable
		) AS SystemCount,
		c.InfoBankID, InfoBankShortName, 
		ROW_NUMBER() OVER(PARTITION BY SystemOrder ORDER BY InfoBankOrder, c.InfoBankID) AS InfoBankOrder,
		(
			SELECT COUNT(*)
			FROM dbo.SystemBankTable z
			WHERE z.SystemID = a.SystemID
		) AS InfoBankCount
	FROM 
		(
			SELECT SystemID, SystemShortName, ROW_NUMBER() OVER(ORDER BY SystemOrder, SystemID) AS SystemOrder
			FROM dbo.SystemTable 
		) AS a INNER JOIN dbo.SystemBankTable b ON a.SystemID = b.SystemID
		INNER JOIN dbo.InfoBankTable c ON c.InfoBankID = b.InfoBankID
	ORDER BY SystemOrder, SystemID, InfoBankOrder, InfoBankID
END