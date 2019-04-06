USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MANAGER_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ManagerName, ManagerLogin, ManagerFullName
	FROM dbo.ManagerTable
	WHERE ManagerID = @ID
END