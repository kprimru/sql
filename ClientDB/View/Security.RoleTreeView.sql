USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[RoleTreeView]', 'V ') IS NULL EXEC('CREATE VIEW [Security].[RoleTreeView]  AS SELECT 1')
GO
ALTER VIEW [Security].[RoleTreeView]
AS
	WITH CTE AS
	(
		SELECT RoleID, RoleMasterID, RoleName, Cast(RoleCaption AS VarChar(Max)) AS RoleCaption
		FROM Security.Roles AS R
		WHERE RoleMasterID IS NULL

		UNION ALL

		SELECT R.RoleID, R.RoleMasterID, R.RoleName, Cast(C.RoleCaption + '::' + R.RoleCaption AS VarChar(Max))
		FROM Security.Roles AS R
		INNER JOIN CTE AS C ON C.RoleID = R.RoleMasterID
	)
	SELECT *
	FROM CTE
GO
