﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PERSONAL_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[PERSONAL_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[PERSONAL_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(PERMS_LAST)
	FROM	Personal.Personals
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_LAST] TO rl_personal_r;
GO
