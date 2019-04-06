USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COURIER_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ServiceID, ServiceName, a.ManagerID, ManagerName, ServiceFullName,
		(
			SELECT COUNT(*)
			FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
			WHERE ClientServiceID = ServiceID
		) AS ServiceCount
	FROM 
		[PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable a INNER JOIN
		[PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable b ON a.ManagerID = b.ManagerID
	ORDER BY ServiceName
END
