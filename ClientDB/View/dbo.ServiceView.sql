USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ServiceView]
WITH SCHEMABINDING
AS
	SELECT ServiceID, ServiceName, ServiceLogin
	FROM dbo.ServiceTable
	WHERE ServiceDismiss IS NULL
