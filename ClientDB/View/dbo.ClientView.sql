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
	WHERE a.STATUS = 1GO
