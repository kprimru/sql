USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USER_DELETE]
	@US_NAME	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT *
			FROM sys.database_principals
			WHERE [name] = @US_NAME
				AND [type] = 'U'
		)
	EXEC('DROP USER [' + @US_NAME + ']')
END
GRANT EXECUTE ON [dbo].[USER_DELETE] TO rl_admin;
GO