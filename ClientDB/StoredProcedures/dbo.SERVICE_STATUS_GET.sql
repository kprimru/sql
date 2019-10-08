USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATUS_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceStatusName, ServiceStatusReg, ServiceStatusIndex, ServiceDefault, ServiceCode
	FROM dbo.ServiceStatusTable
	WHERE ServiceStatusID = @ID
END