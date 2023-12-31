USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Security].[ROLE_TREE_SELECT]
(
	@RL_ID UNIQUEIDENTIFIER
)
RETURNS TABLE
AS
RETURN
	(
	WITH RolesTree(RL_ID, RL_ID_MASTER, RL_NAME, RL_ROLE) AS
		(
			SELECT RL_ID, RL_ID_MASTER, RL_NAME, RL_ROLE
			FROM Security.Roles
			WHERE RL_ID_MASTER  = @RL_ID

			UNION ALL

			SELECT a.RL_ID, a.RL_ID_MASTER, a.RL_NAME, a.RL_ROLE
			FROM
				Security.Roles a INNER JOIN
				RolesTree b ON a.RL_ID_MASTER = b.RL_ID
			WHERE a.RL_ID_MASTER IS NOT NULL
		)

	SELECT *
	FROM RolesTree
	WHERE RL_ROLE IS NOT NULL
	UNION ALL
	SELECT *
	FROM Security.Roles
	WHERE RL_ID = @RL_ID
	)
GO
