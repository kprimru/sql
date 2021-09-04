USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientView]
WITH SCHEMABINDING
AS
	SELECT
		ClientID, ClientFullName,
		ServiceID, ServiceName, ServiceLogin,
		c.ManagerID, ManagerName, ManagerLogin,
		ServiceStatusID, ServiceStatusName, ServiceStatusIndex,
		ServiceTypeID, ClientKind_Id, OriClient, ClientTypeId
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.StatusID
	WHERE a.STATUS = 1
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientView(ClientID)] ON [dbo].[ClientView] ([ClientID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ClientID)+(ManagerName,ServiceName)] ON [dbo].[ClientView] ([ClientID] ASC) INCLUDE ([ManagerName], [ServiceName]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ManagerID,ServiceStatusID)+INCL] ON [dbo].[ClientView] ([ManagerID] ASC, [ServiceStatusID] ASC) INCLUDE ([ClientFullName], [ClientID], [ManagerName], [ServiceID], [ServiceName], [ServiceStatusName], [ServiceTypeID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ManagerLogin)+(ClientID)] ON [dbo].[ClientView] ([ManagerLogin] ASC) INCLUDE ([ClientID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ManagerLogin,OriClient,ServiceLogin)] ON [dbo].[ClientView] ([ManagerLogin] ASC, [OriClient] ASC, [ServiceLogin] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ServiceID,ServiceStatusID)+INCL] ON [dbo].[ClientView] ([ServiceID] ASC, [ServiceStatusID] ASC) INCLUDE ([ClientFullName], [ClientID], [ManagerID], [ManagerName], [ServiceName], [ServiceTypeID], [ServiceStatusName]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ServiceLogin)+(ClientID)] ON [dbo].[ClientView] ([ServiceLogin] ASC) INCLUDE ([ClientID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ServiceStatusID,ServiceID,ManagerID)+INCL] ON [dbo].[ClientView] ([ServiceStatusID] ASC, [ServiceID] ASC, [ManagerID] ASC) INCLUDE ([ClientFullName], [ClientID], [ManagerName], [ServiceName], [ServiceStatusName], [ServiceTypeID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientView(ServiceStatusID,ServiceTypeID)+(ClientID,ServiceID,ManagerID)] ON [dbo].[ClientView] ([ServiceStatusID] ASC, [ServiceTypeID] ASC) INCLUDE ([ClientID], [ServiceID], [ManagerID]);
GO
