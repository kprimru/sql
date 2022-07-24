SELECT
	[UserName]	= u.name,
	[Role]		= r.name,
	G.GroupName,
	SR.RoleCaption
FROM sys.database_principals r
INNER JOIN sys.database_role_members rm ON r.principal_id = rm.role_principal_id
INNER JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
OUTER APPLY
(
	SELECT [GroupName] = String_Agg(RT.RoleStr, ',')
	FROM sys.database_role_members AS grm
	INNER JOIN sys.database_principals AS gr ON gr.principal_id = grm.role_principal_id
	INNER JOIN dbo.RoleTable AS RT ON RT.RoleName = gr.name
	WHERE grm.member_principal_id = u.principal_id
		AND gr.name LIKE 'DB%'
) AS G
OUTER APPLY
(
	SELECT TOP (1) SR.RoleCaption
	FROM Security.RoleTreeView AS SR
	WHERE SR.RoleName = r.name
) AS SR
/*
OUTER APPLY
(
	SELECT TOP (1) [GroupName] = gr.name
	FROM sys.database_role_members AS grm
	INNER JOIN sys.database_principals AS gr ON gr.principal_id = grm.role_principal_id
	INNER JOIN sys.database_role_members AS grm2 ON grm2.role_principal_id = r.principal_id AND grm2.member_principal_id = grm.role_principal_id
	WHERE grm.member_principal_id = u.principal_id
		AND gr.name LIKE 'DB%'
) AS grm
*/
WHERE u.type <> 'R' AND r.name like 'rl_%'
ORDER BY u.name, r.name