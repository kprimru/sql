USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTROL_WARNING_LAST]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT MAX(CC_DATE) AS LAST_DATE
	FROM 
		dbo.ClientWriteList()
		INNER JOIN dbo.ClientControl a ON CC_ID_CLIENT = WCL_ID
		INNER JOIN dbo.ClientTable b ON ClientID = CC_ID_CLIENT
		INNER JOIN dbo.ServiceTable c ON c.ServiceID = ClientServiceID
		INNER JOIN dbo.ManagerTable d ON d.ManagerID = c.ManagerID
	WHERE CC_READ_DATE IS NULL 
		AND IS_MEMBER('rl_control_warning') = 1
END