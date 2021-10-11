USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Security].[RoleUserView]
AS
	SELECT a.name AS RL_NAME, c.name AS US_NAME, 1 AS RL_DIRECT
	FROM
		Security.Roles
		INNER JOIN sys.database_principals a ON a.name = RoleName
		INNER JOIN sys.database_role_members b ON b.role_principal_id = a.principal_id
		INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id

	UNION ALL

	SELECT e.name, a.name, 0
	FROM 
		sys.database_principals a
		INNER JOIN sys.database_role_members b ON b.member_principal_id = a.principal_id
		INNER JOIN sys.database_principals c ON b.role_principal_id = c.principal_id
		INNER JOIN sys.database_role_members d ON d.member_principal_id = c.principal_id
		INNER JOIN sys.database_principals e ON d.role_principal_id = e.principal_id
		INNER JOIN Security.Roles ON RoleName = e.nameGO
