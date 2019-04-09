USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_AUDIT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientID, ClientFullName, ServiceName, ManagerName
	FROM 
		dbo.ClientAudit
		INNER JOIN dbo.ClientTable a ON CA_ID_CLIENT = ClientID
		INNER JOIN dbo.ClientWriteList() ON WCL_ID = ClientID
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
	WHERE CA_CONTROL = 1 AND a.STATUS = 1
	ORDER BY CA_DATE DESC
END