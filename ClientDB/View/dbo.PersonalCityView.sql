USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PersonalCityView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[PersonalCityView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[PersonalCityView]
WITH SCHEMABINDING
AS
	SELECT ServiceID, ServiceName, b.ManagerID, ManagerName, CT_ID, CT_NAME
	FROM
		dbo.ServiceCity a
		INNER JOIN dbo.ServiceTable b ON a.ID_SERVICE = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		INNER JOIN dbo.City d ON d.CT_ID = a.ID_CITY

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.PersonalCityView(ServiceID,CT_ID)] ON [dbo].[PersonalCityView] ([ServiceID] ASC, [CT_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PersonalCityView(ManagerID,CT_ID)] ON [dbo].[PersonalCityView] ([ManagerID] ASC, [CT_ID] ASC);
GO
