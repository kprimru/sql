USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[BL_USER_ADD]
	@USER   VARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DB   VARCHAR(128)
	DECLARE @ERROR VARCHAR(MAX)		

	IF (CHARINDEX('''', @USER) <> 0)
	BEGIN
		SET @ERROR = 'Имя пользователя или пароль содержат недоспустимые символы (кавычка)'

		RAISERROR (@ERROR, 16, 1)

		RETURN
	END
    SET @DB = DB_NAME()
	IF  NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = @USER)
	BEGIN
		EXEC('CREATE LOGIN [' + @USER + '] FROM WINDOWS WITH DEFAULT_DATABASE ='+@DB)
	END

	IF  EXISTS (SELECT * FROM sys.server_principals WHERE [name] = @USER)
    BEGIN
		IF  NOT EXISTS (SELECT * FROM sys.database_principals WHERE [name] = @USER)
		BEGIN
			EXEC('CREATE USER [' + @USER+ '] FOR LOGIN [' + @USER+']')
		END
    END
END