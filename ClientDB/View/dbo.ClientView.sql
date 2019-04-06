USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientView]
WITH SCHEMABINDING
AS
	SELECT 
		ClientID, ClientFullName, 
		ServiceID, ServiceName, ServiceLogin,
		c.ManagerID, ManagerName, ManagerLogin,
		ServiceStatusID, ServiceStatusName, ServiceStatusIndex,
		ServiceTypeID
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.StatusID
	WHERE a.STATUS = 1