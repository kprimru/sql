USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[STAT_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT CONVERT(VARCHAR(20), StatisticDate, 112) AS StatisticDate, SystemBaseName, InfoBankName, Docs
	FROM 
		dbo.StatisticTable a 
		INNER JOIN dbo.InfoBankTable b ON a.InfoBankID = b.InfoBankID
		INNER JOIN dbo.SystemBankTable c ON c.InfoBankID = b.InfoBankID
		INNER JOIN dbo.SystemTable d ON d.SystemID = c.SystemID
	WHERE StatisticDate >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
END