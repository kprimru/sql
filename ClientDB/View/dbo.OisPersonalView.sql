USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[OisPersonalView]
AS
	SELECT ServiceID, ServiceName, ServiceLogin
	FROM dbo.ServiceTable a
	WHERE ServiceDismiss IS NULL
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientTable b
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
				WHERE STATUS = 1
					AND ClientServiceID = ServiceID
			)

	UNION ALL

	SELECT ManagerID, ManagerName, ManagerLogin
	FROM dbo.ManagerTable a
	WHERE EXISTS
			(
				SELECT *
				FROM
					dbo.ClientTable b
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
					INNER JOIN dbo.ServiceTable c ON ServiceID = ClientServiceID
				WHERE STATUS = 1
					AND a.ManagerID = c.ManagerID
			)
