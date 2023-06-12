USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_CREATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_CREATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[USER_CREATE]
	@AUTH	SMALLINT,
	@LOGIN	NVARCHAR(128),
	@NAME	NVARCHAR(128),
	@PASS	NVARCHAR(128),
	@ROLE	UNIQUEIDENTIFIER,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	DECLARE @ER_TXT NVARCHAR(2048)
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @TYPE	TINYINT

	DECLARE @LG_EXISTS	BIT
	DECLARE @US_EXISTS	BIT

	DECLARE @GROUP NVARCHAR(128)

	SELECT @GROUP = NAME
	FROM Security.RoleGroup
	WHERE ID = @ROLE

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	IF EXISTS
		(
			SELECT * FROM sys.server_principals WHERE name = @LOGIN
		)
		SET @LG_EXISTS = 1
	ELSE
		SET @LG_EXISTS = 0

	IF EXISTS
		(
			SELECT * FROM sys.database_principals WHERE name = @LOGIN
		)
		SET @US_EXISTS = 1
	ELSE
		SET @US_EXISTS = 0


	BEGIN TRY
		IF @AUTH = 1
		BEGIN
			-- доменный пользователь
			IF @LG_EXISTS = 1
			BEGIN
				SET @ER_TXT = 'Пользователь или роль "' + @LOGIN + '" уже существует на сервере. Выберите другое имя.'

				RAISERROR(@ER_TXT, 16, 1)
			END
			ELSE IF @US_EXISTS = 1
			BEGIN
				SET @ER_TXT = 'Пользователь или роль "' + @LOGIN + '" уже существует в базе данных. Выберите другое имя.'

				RAISERROR(@ER_TXT, 16, 1)
			END
			ELSE
			BEGIN
				IF @LG_EXISTS = 0
				BEGIN
					SET @SQL = N'CREATE LOGIN ' + QUOTENAME(@LOGIN) + ' FROM WINDOWS'
					EXEC (@SQL)
				END

				IF @US_EXISTS = 0
				BEGIN
					SET @SQL = 'CREATE USER ' + QUOTENAME(@LOGIN) + ' FOR LOGIN ' + QUOTENAME(@LOGIN, '''')
					EXEC (@SQL)
				END

				EXEC sp_addrolemember 'gr_all', @LOGIN
				EXEC sp_addrolemember @GROUP, @LOGIN

				SET @TYPE = 1
			END
		END
		ELSE IF @AUTH = 2
		BEGIN
			-- только SQL пользователь
			IF @LG_EXISTS = 1
			BEGIN
				SET @ER_TXT = 'Пользователь или роль "' + @LOGIN + '" уже существует на сервере. Выберите другое имя.'

				RAISERROR(@ER_TXT, 16, 1)
			END
			ELSE IF @US_EXISTS = 1
			BEGIN
				SET @ER_TXT = 'Пользователь или роль "' + @LOGIN + '" уже существует в базе данных. Выберите другое имя.'

				RAISERROR(@ER_TXT, 16, 1)
			END
			ELSE
			BEGIN
				SET @SQL = N'CREATE LOGIN ' + QUOTENAME(@LOGIN) + ' WITH PASSWORD = ' + QUOTENAME(@PASS, '''') + ', CHECK_POLICY = OFF'
				EXEC (@SQL)
				SET @SQL = 'CREATE USER ' + QUOTENAME(@LOGIN) + ' FOR LOGIN ' + QUOTENAME(@LOGIN)
				EXEC (@SQL)

				EXEC sp_addrolemember 'gr_all', @LOGIN
				EXEC sp_addrolemember @GROUP, @LOGIN

				SET @TYPE = 2
			END
		END
		ELSE
		BEGIN
			RAISERROR('Ошибка глобальных настроек базы данных. Не задан параметр авторизации пользователей', 16, 1)
		END

		IF @TYPE IS NOT NULL
		BEGIN
			INSERT INTO Security.Users(LOGIN, NAME, TYPE)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@LOGIN, @NAME, @TYPE)

			SELECT @ID = ID FROM @TBL
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_CREATE] TO rl_user_w;
GO
