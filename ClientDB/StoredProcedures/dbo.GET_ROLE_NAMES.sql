USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_ROLE_NAMES] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT RoleID, RoleName, RoleStr 
	FROM dbo.RoleTable 
	ORDER BY RoleName
END