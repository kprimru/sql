USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ClientList@Get]
(
	@ListType VarChar(100)
)
RETURNS TABLE
AS
RETURN
(
	SELECT W.ClientID
	FROM
	(
		SELECT TOP (1)
				LST_ALL,
				LST_MANAGER,
				LST_SERVICE,
				LST_ORI
		FROM
		(
			SELECT
				1 AS ORD,
				LST_ALL,
				LST_MANAGER,
				LST_SERVICE,
				LST_ORI
			FROM Security.ClientList
			WHERE	LST_TYPE = @ListType
				AND LST_USER = ORIGINAL_LOGIN()

			UNION ALL

			SELECT
				2 AS ORD,
				CONVERT(BIT, MAX(CONVERT(INT, LST_ALL))),
				CONVERT(BIT, MAX(CONVERT(INT, LST_MANAGER))),
				CONVERT(BIT, MAX(CONVERT(INT, LST_SERVICE))),
				CONVERT(BIT, MAX(CONVERT(INT, LST_ORI)))
			FROM
				Security.ClientList
				INNER JOIN dbo.RoleTable ON RoleName = LST_USER
				INNER JOIN sys.database_principals a ON a.name = RoleName
				INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
				INNER JOIN sys.database_principals c ON b.member_principal_id = c.principal_id
			WHERE c.name = ORIGINAL_LOGIN() AND LST_TYPE = @ListType
		) AS C
		ORDER BY C.ORD
	) AS C
	CROSS APPLY
	(
		SELECT ClientID
		FROM dbo.ClientView W WITH(NOEXPAND)
		WHERE	C.LST_ALL = 1
			OR (C.LST_MANAGER = 1 AND W.ManagerLogin = ORIGINAL_LOGIN())
			OR (C.LST_SERVICE = 1 AND W.ServiceLogin = ORIGINAL_LOGIN())
			OR (C.LST_ORI = 1 AND W.OriClient = 1)
	) W
)
GO
