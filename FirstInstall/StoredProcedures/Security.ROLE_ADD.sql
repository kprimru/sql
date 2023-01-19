﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_ADD]
	@BASE	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100),
	@ROLE	VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Security.Roles(RL_ID_MASTER, RL_NAME, RL_ROLE)
	VALUES (@BASE, @NAME, @ROLE)

	IF @ROLE <> ''
		EXEC ('CREATE ROLE [' + @ROLE + ']')
END
GO
