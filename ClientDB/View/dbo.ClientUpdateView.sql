USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[ClientUpdateView]
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