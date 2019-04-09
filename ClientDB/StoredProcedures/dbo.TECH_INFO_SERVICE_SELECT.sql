USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TECH_INFO_SERVICE_SELECT]
	@MANAGER INT,
	@SERVICE INT
AS
BEGIN
	SET NOCOUNT ON;

		SELECT 
			b.ManagerID, ManagerName, ServiceID, ServiceName, 
			ServiceFullName, ServicePhone, 
			(
				SELECT COUNT(*) 
				FROM dbo.ClientTable 
				WHERE ClientServiceID = ServiceID
					AND STATUS = 1
			) AS ServiceCount 
		FROM 
			dbo.ServiceTable a INNER JOIN 
    		dbo.ManagerTable b ON a.ManagerID = b.ManagerID 
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (b.ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ServiceName
END