USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[USER_CREATE]
	@NAME	VARCHAR(50),
	@PASS	VARCHAR(50),
	@ROLES	VARCHAR(MAX),
	@AUTH	TINYINT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ERROR VARCHAR(MAX)		

	IF (CHARINDEX('''', @NAME) <> 0)
		OR (CHARINDEX('''', @PASS) <> 0)
	BEGIN
		SET @ERROR = '»м€ пользовател€ или пароль содержат недоспустимые символы (кавычка)'

		RAISERROR (@ERROR, 16, 1)

		RETURN
	END

	/*
	IF EXISTS(
			SELECT *
			FROM sys.server_principals
			WHERE name = @NAME
		)
	BEGIN
		SET @ERROR = 'ѕользователь "' + @NAME + '" уже есть на сервере'
		
		RAISERROR (@ERROR, 16, 1)

		RETURN
	END
	*/
	

	IF EXISTS(
			SELECT *
			FROM sys.database_principals
			WHERE name = @NAME
		)
	BEGIN		
		SET @ERROR = 'ѕользователь или роль "' + @NAME + '" уже существуют в базе данных'
		
		RAISERROR (@ERROR, 16, 1)

		RETURN
	END

	IF @AUTH = 0
	BEGIN
		IF NOT EXISTS
			(
				SELECT *
				FROM sys.server_principals
				WHERE name = @NAME
			)
		/* авторизаци€ Windows*/
			EXEC('CREATE LOGIN [' + @NAME + '] FROM WINDOWS')		
	END
	ELSE
	BEGIN
		IF NOT EXISTS
			(
				SELECT *
				FROM sys.server_principals
				WHERE name = @NAME
			)
		/* авторизаци€ SQL		*/
			EXEC('CREATE LOGIN [' + @NAME + '] WITH PASSWORD = ''' + @PASS + ''', CHECK_POLICY = OFF ')		
	END

	EXEC('CREATE USER [' + @NAME + '] FOR LOGIN [' + @NAME + ']')

	DECLARE RL CURSOR LOCAL FOR
		SELECT ID
		FROM dbo.TableStringFromXML(@ROLES)

	OPEN RL
	
	DECLARE @RL	VARCHAR(50)

	FETCH NEXT FROM RL INTO @RL

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXEC sp_addrolemember @RL, @NAME

		FETCH NEXT FROM RL INTO @RL
	END

	CLOSE RL
	DEALLOCATE RL
END