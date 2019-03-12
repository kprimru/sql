USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONTROL_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientID, ClientFullName, ManagerName, CC_TEXT, CC_DATE, CC_BEGIN
	FROM 
		dbo.ClientWriteList()
		INNER JOIN dbo.ClientControl a ON CC_ID_CLIENT = WCL_ID
		INNER JOIN dbo.ClientTable b ON ClientID = CC_ID_CLIENT
		INNER JOIN dbo.ServiceTable c ON c.ServiceID = ClientServiceID
		INNER JOIN dbo.ManagerTable d ON c.ManagerID = d.ManagerID
	WHERE /*CC_READ_DATE IS NULL AND */CC_REMOVE_DATE IS NULL
		AND (CC_BEGIN IS NULL OR CC_BEGIN <= GETDATE())
		AND (IS_MEMBER('rl_control_warning') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1)
	ORDER BY ClientFullName
END