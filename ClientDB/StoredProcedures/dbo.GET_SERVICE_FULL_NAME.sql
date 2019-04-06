USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SERVICE_FULL_NAME]
	@serviceid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT ServiceFullName, ManagerName
	FROM 
		dbo.ServiceTable a LEFT OUTER JOIN
		dbo.ManagerTable b ON a.ManagerID = b.ManagerID
	WHERE ServiceID = @serviceid
END