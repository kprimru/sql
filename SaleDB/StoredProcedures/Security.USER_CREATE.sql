USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
			-- �������� ������������
			IF @LG_EXISTS = 1
			BEGIN
				SET @ER_TXT = '������������ ��� ���� "' + @LOGIN + '" ��� ���������� �� �������. �������� ������ ���.'

				RAISERROR(@ER_TXT, 16, 1)
			END
			ELSE IF @US_EXISTS = 1
			BEGIN
				SET @ER_TXT = '������������ ��� ���� "' + @LOGIN + '" ��� ���������� � ���� ������. �������� ������ ���.'

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
			-- ������ SQL ������������
			IF @LG_EXISTS = 1
			BEGIN
				SET @ER_TXT = '������������ ��� ���� "' + @LOGIN + '" ��� ���������� �� �������. �������� ������ ���.'

				RAISERROR(@ER_TXT, 16, 1)
			END
			ELSE IF @US_EXISTS = 1
			BEGIN
				SET @ER_TXT = '������������ ��� ���� "' + @LOGIN + '" ��� ���������� � ���� ������. �������� ������ ���.'

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
			RAISERROR('������ ���������� �������� ���� ������. �� ����� �������� ����������� �������������', 16, 1)
		END

		IF @TYPE IS NOT NULL
		BEGIN
			INSERT INTO Security.Users(LOGIN, NAME, TYPE)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@LOGIN, @NAME, @TYPE)

			SELECT @ID = ID FROM @TBL
		END
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GRANT EXECUTE ON [Security].[USER_CREATE] TO rl_user_w;
GO