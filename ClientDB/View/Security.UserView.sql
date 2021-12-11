USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[UserView]', 'V ') IS NULL EXEC('CREATE VIEW [Security].[UserView]  AS SELECT 1')
GO
ALTER VIEW [Security].[UserView]
AS
	SELECT principal_id AS US_ID, name AS US_SQL_NAME, name AS US_NAME, 1 AS US_USER
	FROM sys.database_principals
	WHERE [TYPE] IN ('S', 'U')
		AND name NOT IN
			(
				'INFORMATION_SCHEMA', 'dbo', 'guest', 'sys'
			)
	UNION ALL

	SELECT principal_id, name, RoleStr, 0 AS US_USER
	FROM
		sys.database_principals
		INNER JOIN dbo.RoleTable ON RoleName = name
	WHERE [TYPE] = 'R'GO
