USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_ROLES_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_ROLES_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[USER_ROLES_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT us.name AS USR_NAME, rl.NAME AS ROLE_NAME, lg.NAME
	FROM
		sys.database_principals AS us INNER JOIN
		sys.database_role_members AS rm ON rm.member_principal_id = us.principal_id INNER JOIN
		sys.database_principals AS rl ON rm.role_principal_id = rl.principal_id INNER JOIN
		sys.server_principals AS lg ON lg.sid = us.sid
	WHERE us.name = ORIGINAL_LOGIN()
	ORDER BY USR_NAME, ROLE_NAME
END
GO
GRANT EXECUTE ON [Security].[USER_ROLES_SELECT] TO public;
GO
