USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SystemDocsView]
AS
	SELECT SystemID, SystemBaseName, FLOOR(SUM(Docs) / 100.0) * 100 AS Docs
	FROM 	
		dbo.SystemBanksView a WITH(NOEXPAND)
		INNER JOIN 
			(
				SELECT InfoBankID, Docs
				FROM dbo.StatisticTable c
				WHERE StatisticDate = 
					(
						SELECT MAX(StatisticDate) 
						FROM dbo.StatisticTable d 
						WHERE d.InfoBankID = c.InfoBankID
					)
			) b ON a.InfoBankID = b.InfoBankID
	GROUP BY SystemID, SystemBaseName