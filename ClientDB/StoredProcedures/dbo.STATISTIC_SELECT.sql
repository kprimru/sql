USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[STATISTIC_SELECT]
	@DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemFullName, InfoBankFullName, InfoBankName, Docs
	FROM 
		dbo.StatisticTable a INNER JOIN
		dbo.SystemBanksView b WITH(NOEXPAND) ON a.InfoBankID = b.InfoBankID
	WHERE StatisticDate = @DATE
		AND SystemActive = 1
		AND InfoBankActive = 1
		AND Required IN (1, 2)
	ORDER BY SystemOrder, InfoBankOrder
END