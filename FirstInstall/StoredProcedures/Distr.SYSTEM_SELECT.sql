USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SYSTEM_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		SYS_ID_MASTER, SYS_ID,
		SYS_SHORT, SYS_MAIN, SYS_NAME, SYS_DATE, SYS_END, SYS_ORDER, SYS_REG
	FROM
		[Distr].[SystemActive]

	SELECT @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[SYSTEM_SELECT] TO rl_system_r;
GO