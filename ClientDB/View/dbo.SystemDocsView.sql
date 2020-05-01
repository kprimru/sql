USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[SystemDocsView]
AS
	/*SELECT SystemID, SystemBaseName, FLOOR(SUM(Docs) / 100.0) * 100 AS Docs
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
	GROUP BY SystemID, SystemBaseName*/
	SELECT a.SystemID, a.SystemBaseName, SUM(Docs) AS Docs
	FROM dbo.SystemTable a
	--ToDo злостный хардкод
	CROSS APPLY dbo.SystemBankGet(a.SystemId, 2) b
	CROSS APPLY
	(
		SELECT TOP (1) C.Docs
		FROM dbo.StatisticTable c
		WHERE c.InfoBankID = b.InfoBankID
		ORDER BY c.StatisticDate DESC
	) c
	GROUP BY a.SystemID, a.SystemBaseName