USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ServiceView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ServiceView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [dbo].[ServiceView]
WITH SCHEMABINDING
AS
	SELECT ServiceID, ServiceName, ServiceLogin
	FROM dbo.ServiceTable
	WHERE ServiceDismiss IS NULL

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ServiceView(ServiceID)] ON [dbo].[ServiceView] ([ServiceID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ServiceView(ServiceName)] ON [dbo].[ServiceView] ([ServiceName] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ServiceView(ServiceLogin)] ON [dbo].[ServiceView] ([ServiceLogin] ASC);
GO
