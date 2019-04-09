USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientConnectView]
WITH SCHEMABINDING
AS
	SELECT a.ClientID, dbo.DateOf(RPR_DATE) AS ConnectDate, COUNT_BIG(*) AS CNT
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ClientDistr c ON c.ID_CLIENT = a.ClientID
		INNER JOIN dbo.DistrStatus d ON d.DS_ID = c.ID_STATUS	
		INNER JOIN dbo.SystemTable e ON e.SystemID = c.ID_SYSTEM
		INNER JOIN dbo.RegProtocol f ON f.RPR_ID_HOST = e.HostID AND f.RPR_DISTR = c.DISTR AND f.RPR_COMP = c.COMP
	WHERE /*DS_REG = 0 AND *//*RPR_OPER = 'ÍÎÂÀß' AND */a.STATUS = 1 AND c.STATUS = 1
	GROUP BY a.ClientID, dbo.DateOf(RPR_DATE)