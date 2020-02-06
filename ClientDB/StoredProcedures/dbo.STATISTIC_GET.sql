USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STATISTIC_GET]
	@DATE		SMALLDATETIME,
	@SYSTEM_ID	INT	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		a.[InfoBankID], a.[InfoBankName], a.[InfoBankFullName],
		(
			SELECT TOP 1 b.DOCS
			FROM dbo.StatisticTable b 
			WHERE	b.InfoBankID = a.InfoBankID
				AND b.StatisticDate <= @DATE
			ORDER BY StatisticDate DESC
		) as DOCS
	FROM [dbo].[SystemBanksView] a
	WHERE a.SystemID = @SYSTEM_ID
	ORDER BY a.InfoBankOrder
END
