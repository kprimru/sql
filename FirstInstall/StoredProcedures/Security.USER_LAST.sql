USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(USMS_LAST)
	FROM	Security.Users
END
GO
GRANT EXECUTE ON [Security].[USER_LAST] TO rl_user_r;
GO
