﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[HALF_DELETED]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[HALF_DELETED]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[HALF_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Common].[HalfDeleted]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Common].[HALF_DELETED] TO rl_half_r;
GO
