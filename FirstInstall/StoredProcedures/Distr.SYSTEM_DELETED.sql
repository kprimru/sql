﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[SYSTEM_DELETED]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[SYSTEM_DELETED]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[SYSTEM_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT [Distr].[SystemDeleted].*, HST_ID_MASTER, HST_NAME
	FROM
		[Distr].[SystemDeleted]	INNER JOIN
		[Distr].[HostLast]		ON HST_ID_MASTER = SYS_ID_HOST

	SELECT @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[SYSTEM_DELETED] TO rl_system_r;
GO
