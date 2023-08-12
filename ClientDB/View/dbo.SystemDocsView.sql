﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemDocsView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[SystemDocsView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [dbo].[SystemDocsView]
AS
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
GO
