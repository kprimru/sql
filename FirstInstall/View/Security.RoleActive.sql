USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Security].[RolesActive]
--WITH SCHEMABINDING
AS
	SELECT
		RL_ID, RL_ID_MASTER, RL_NAME, RL_ROLE, ROLE_CREATE
	FROM
		Security.Roles LEFT OUTER JOIN
		Security.DBRoles ON ROLE_NAME = RL_ROLE

		GO
