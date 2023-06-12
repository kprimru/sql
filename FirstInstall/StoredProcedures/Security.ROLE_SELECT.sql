﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		RL_ID, RL_ID_MASTER, RL_NAME, RL_ROLE, ROLE_CREATE
	FROM
		Security.RoleActive
END
GO
