USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Security].[UserRoleView]
AS
	WITH user_roles AS
			(
				SELECT r.name AS RL_NAME, r.principal_id AS RL_ID, u.NAME AS US_NAME
				FROM
					sys.database_principals u
					INNER JOIN sys.database_role_members ur ON u.principal_id = ur.member_principal_id
					INNER JOIN sys.database_principals r ON r.principal_id = ur.role_principal_id
				WHERE u.TYPE IN ('S', 'U')

				UNION ALL

				SELECT r.name AS RL_NAME, r.principal_id AS RL_ID, u.US_NAME
				FROM
					user_roles u
					INNER JOIN sys.database_role_members ur ON u.RL_ID = ur.member_principal_id
					INNER JOIN sys.database_principals r ON r.principal_id = ur.role_principal_id
			)
		SELECT RL_NAME, US_NAME
		FROM
			user_roles a
	GO
