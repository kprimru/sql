USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientSystemErrorView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientSystemErrorView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientSystemErrorView]
WITH SCHEMABINDING
AS
	SELECT
		a.ClientID, COUNT_BIG(*) AS CNT
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ClientDistr b ON a.ClientID = b.ID_CLIENT
		INNER JOIN dbo.DistrStatus c ON b.ID_STATUS = c.DS_ID
		INNER JOIN dbo.SystemTable d ON b.ID_SYSTEM = d.SystemID
		INNER JOIN dbo.RegNodeTable e ON d.SystemBaseName = e.SystemName
									AND b.DISTR = e.DistrNumber
									AND	b.COMP = e.CompNumber
	WHERE c.DS_REG <> e.Service AND a.STATUS = 1 AND b.STATUS = 1
	GROUP BY a.ClientID

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientSystemErrorView(ClientID)] ON [dbo].[ClientSystemErrorView] ([ClientID] ASC);
GO
