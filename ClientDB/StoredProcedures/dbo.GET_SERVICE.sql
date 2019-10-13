USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SERVICE] AS
BEGIN
	SET NOCOUNT ON

	SELECT ServiceID, ServiceName, 
		(
			SELECT COUNT(*)
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			WHERE ClientServiceID = ServiceID
				AND STATUS = 1
		) AS ServiceCount, ManagerID
	FROM dbo.ServiceTable
	ORDER BY ServiceName
END