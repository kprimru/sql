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
			FROM dbo.ClientTable
			WHERE ClientServiceID = ServiceID
				AND StatusID = 2
				AND STATUS = 1
		) AS ServiceCount, ManagerID
	FROM dbo.ServiceTable
	ORDER BY ServiceName
END