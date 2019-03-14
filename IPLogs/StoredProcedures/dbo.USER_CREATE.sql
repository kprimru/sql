USE [IPLogs]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[USER_CREATE]
	@US_NAME	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS
		(
			SELECT *
			FROM sys.server_principals
			WHERE [name] = @US_NAME
				AND [type] = 'U'
		)
	BEGIN
		EXEC('CREATE LOGIN [' + @US_NAME + '] FROM WINDOWS')
	END

	IF EXISTS
		(
			SELECT *
			FROM sys.server_principals
			WHERE [name] = @US_NAME
				AND [type] = 'U'
		)
	BEGIN
		EXEC('CREATE USER [' + @US_NAME + '] FOR LOGIN [' + @US_NAME + ']')

		EXEC sp_addrolemember 'rl_common', @US_NAME
	END		
END
