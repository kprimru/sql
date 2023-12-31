USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_ACT_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(IAMS_LAST)
	FROM	Install.InstallAct
END
GO
GRANT EXECUTE ON [Install].[INSTALL_ACT_LAST] TO rl_install_act_r;
GO
