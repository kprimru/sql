USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OisPersonalView]
AS
	SELECT ServiceID, ServiceName, ServiceLogin
	FROM dbo.ServiceTable a
	WHERE ServiceDismiss IS NULL 
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientTable b
				WHERE STATUS = 1 
					AND ClientServiceID = ServiceID
					AND StatusID = 2
			)
			
	UNION ALL
	
	SELECT ManagerID, ManagerName, ManagerLogin
	FROM dbo.ManagerTable a
	WHERE EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientTable b
					INNER JOIN dbo.ServiceTable c ON ServiceID = ClientServiceID
				WHERE STATUS = 1 
					AND a.ManagerID = c.ManagerID
					AND StatusID = 2
			)	
