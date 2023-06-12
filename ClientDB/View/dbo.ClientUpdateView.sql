USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientUpdateView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientUpdateView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientUpdateView]
WITH SCHEMABINDING
AS
	SELECT
		ClientID, ID_MASTER, ClientFullName,
		ClientINN, ServiceName, ManagerName, ServiceStatusName,
		ClientLast, UPD_USER
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.StatusID
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientUpdateView(ClientID)] ON [dbo].[ClientUpdateView] ([ClientID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientUpdateView(ClientLast)+(ClientFullName,ClientID,ID_MASTER,ClientINN)] ON [dbo].[ClientUpdateView] ([ClientLast] ASC) INCLUDE ([ClientFullName], [ClientID], [ID_MASTER], [ClientINN]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientUpdateView(ID_MASTER)+(ClientID,ClientLast,UPD_USER)] ON [dbo].[ClientUpdateView] ([ID_MASTER] ASC) INCLUDE ([ClientID], [ClientLast], [UPD_USER]);
GO
