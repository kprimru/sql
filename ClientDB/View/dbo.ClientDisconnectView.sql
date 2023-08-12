﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientDisconnectView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientDisconnectView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [dbo].[ClientDisconnectView]
WITH SCHEMABINDING
AS
	SELECT a.ClientID, dbo.DateOf(RPR_DATE) AS DisconnectDate, COUNT_BIG(*) AS CNT
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable b ON a.StatusID = b.ServiceStatusID
		INNER JOIN dbo.ClientDistr c ON c.ID_CLIENT = a.ClientID
		INNER JOIN dbo.DistrStatus d ON d.DS_ID = c.ID_STATUS
		INNER JOIN dbo.SystemTable e ON e.SystemID = c.ID_SYSTEM
		INNER JOIN dbo.RegProtocol f ON f.RPR_ID_HOST = e.HostID AND f.RPR_DISTR = c.DISTR AND f.RPR_COMP = c.COMP
	WHERE ISNULL(ServiceStatusReg, 1) <> 0 AND DS_REG <> 0 AND RPR_OPER IN ('Отключение', 'Сопровождение отключено') AND a.STATUS = 1 AND c.STATUS = 1
	GROUP BY a.ClientID, dbo.DateOf(RPR_DATE)
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientDisconnectView(DisconnectDate,ClientID)] ON [dbo].[ClientDisconnectView] ([DisconnectDate] ASC, [ClientID] ASC);
GO
