USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_CREATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_CREATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Security].[USER_CREATE]
	@NAME	VARCHAR(50),
	@PASS	VARCHAR(50),
	@ROLES	VARCHAR(MAX),
	@AUTH	TINYINT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @ERROR VARCHAR(MAX)

		IF (CHARINDEX('''', @NAME) <> 0)
			OR (CHARINDEX('''', @PASS) <> 0)
		BEGIN
			SET @ERROR = 'Имя пользователя или пароль содержат недоспустимые символы (кавычка)'

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
			SET @ERROR = 'Пользователь "' + @NAME + '" уже есть на сервере'

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
			SET @ERROR = 'Пользователь или роль "' + @NAME + '" уже существуют в базе данных'

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
			/* авторизация Windows*/
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
			/* авторизация SQL		*/
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_CREATE] TO rl_user_i;
GO
