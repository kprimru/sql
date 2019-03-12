USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientID, ClientFullName, ManagerName, ServiceName, ServiceStatusIndex
	FROM 
		dbo.ClientView WITH(NOEXPAND)
		INNER JOIN dbo.ClientReadList() ON RCL_ID = ClientID
	ORDER BY ClientFullName
END