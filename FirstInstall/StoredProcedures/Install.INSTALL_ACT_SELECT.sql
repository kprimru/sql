USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_ACT_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Install].[InstallActActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Install].[INSTALL_ACT_SELECT] TO rl_install_act_r;
GO