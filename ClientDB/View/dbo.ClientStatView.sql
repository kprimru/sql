USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientStatView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientStatView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientStatView]
WITH SCHEMABINDING
AS
	SELECT c.ID_CLIENT AS ClientID, dbo.DateOf(DATE) AS DATE_S, COUNT_BIG(*) AS CNT
	FROM
		dbo.ClientStat a
		INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
		INNER JOIN dbo.ClientDistr c ON c.ID_SYSTEM = b.SystemID
										AND c.DISTR = a.DISTR
										AND c.COMP = a.COMP
	WHERE c.STATUS = 1
	GROUP BY ID_CLIENT, dbo.DateOf(DATE)
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientStatView(ClientID,DATE_S)] ON [dbo].[ClientStatView] ([ClientID] ASC, [DATE_S] ASC);
GO
