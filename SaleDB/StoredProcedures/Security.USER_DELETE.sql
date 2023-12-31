USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_DELETE]
	@LOGIN	NVARCHAR(128)
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

	BEGIN TRY
		IF OBJECT_ID('tempdb..#users') IS NOT NULL
			DROP TABLE #users

		CREATE TABLE #users
			(
				DB		NVARCHAR(128),
				US		NVARCHAR(128)
			)

		DECLARE @SQL NVARCHAR(MAX)
		DECLARE @DB NVARCHAR(128)

		DECLARE DB CURSOR LOCAL FOR
			SELECT name
			FROM sys.databases
			WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')

		OPEN DB

		FETCH NEXT FROM DB INTO @DB

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = N'INSERT INTO #users (DB, US) SELECT ''' + @DB + ''', a.name FROM ' + @DB + '.sys.database_principals a INNER JOIN sys.server_principals b ON a.sid = b.sid WHERE b.name = @USER'

			EXEC sp_executesql @SQL, N'@USER NVARCHAR(128)', @LOGIN

			FETCH NEXT FROM DB INTO @DB
		END

		CLOSE DB
		DEALLOCATE DB

		DECLARE @US_NAME	NVARCHAR(128)

		SELECT @US_NAME = US
		FROM #users
		WHERE DB = DB_NAME()

		IF EXISTS
			(
				SELECT *
				FROM #users
				WHERE DB <> DB_NAME()
			)
		BEGIN
			IF EXISTS(SELECT * FROM sys.database_principals WHERE name = @US_NAME)
			BEGIN
				SET @SQL = N'DROP USER [' + @US_NAME + ']'
				EXEC (@SQL)
			END
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT * FROM sys.database_principals WHERE name = @US_NAME)
			BEGIN
				SET @SQL = N'DROP USER [' + @US_NAME + ']'
				EXEC (@SQL)
			END

			IF EXISTS(SELECT * FROM sys.server_principals WHERE name = @LOGIN)
			BEGIN
				SET @SQL = N'DROP LOGIN [' + @LOGIN + ']'
				EXEC (@SQL)
			END
		END

		UPDATE Security.Users
		SET STATUS = 3,
			LAST = GETDATE()
		WHERE STATUS = 1
			AND LOGIN = @LOGIN

		IF OBJECT_ID('tempdb..#users') IS NOT NULL
			DROP TABLE #users
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
GO
