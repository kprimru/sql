USE [IPLogs]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[USER_ROLES_SELECT]
	@US_NAME VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT UPPER(rl.NAME) AS RL_NAME
	FROM 
		sys.database_principals AS us INNER JOIN
		sys.database_role_members AS rm ON rm.member_principal_id = us.principal_id INNER JOIN
		sys.database_principals AS rl ON rm.role_principal_id = rl.principal_id INNER JOIN
		sys.server_principals AS lg ON lg.sid = us.sid
	WHERE us.name = @US_NAME
	ORDER BY RL_NAME
END
