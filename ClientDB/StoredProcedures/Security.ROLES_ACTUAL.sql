USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[ROLES_ACTUAL]
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT a.name
	FROM 
		sys.database_principals a
		INNER JOIN sys.database_role_members b ON b.role_principal_id = a.principal_id
		INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
	WHERE c.name = ORIGINAL_LOGIN()

	UNION ALL

	SELECT e.name
	FROM 
		sys.database_principals a
		INNER JOIN sys.database_role_members b ON b.member_principal_id = a.principal_id
		INNER JOIN sys.database_principals c ON b.role_principal_id = c.principal_id
		INNER JOIN sys.database_role_members d ON d.member_principal_id = c.principal_id
		INNER JOIN sys.database_principals e ON d.role_principal_id = e.principal_id
	WHERE a.name = ORIGINAL_LOGIN()
END