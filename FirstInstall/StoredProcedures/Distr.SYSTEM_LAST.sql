USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SYSTEM_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(SYSMS_LAST)
	FROM	Distr.Systems
END
GO
GRANT EXECUTE ON [Distr].[SYSTEM_LAST] TO rl_system_r;
GO
