USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PersonalCityView]
WITH SCHEMABINDING
AS
	SELECT ServiceID, ServiceName, b.ManagerID, ManagerName, CT_ID, CT_NAME
	FROM 
		dbo.ServiceCity a
		INNER JOIN dbo.ServiceTable b ON a.ID_SERVICE = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		INNER JOIN dbo.City d ON d.CT_ID = a.ID_CITY
