USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USER_ADD]
	@USER   VARCHAR(128),
	@LOGIN   VARCHAR(128),
    @PASS VARCHAR(50),
	@WIN  INT,
	@ROLE	VARCHAR(50),
    @ADM  INT,
    @FIO VARCHAR(150) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @DB   VARCHAR(128)
    SET @DB = DB_NAME()
	IF  NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = @LOGIN)
	BEGIN
		if @WIN = 1 EXEC('CREATE LOGIN [' + @LOGIN + '] FROM WINDOWS WITH DEFAULT_DATABASE ='+@DB)
        ELSE EXEC('CREATE LOGIN [' + @LOGIN + '] WITH PASSWORD = ''' + @PASS + ''', DEFAULT_DATABASE ='+@DB+', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF ')
	END

	IF  EXISTS (SELECT * FROM sys.server_principals WHERE [name] = @LOGIN)
    BEGIN
		IF  NOT EXISTS (SELECT * FROM sys.database_principals WHERE [name] = @USER)
		BEGIN
			EXEC('CREATE USER [' + @USER+ '] FOR LOGIN [' + @LOGIN+']')
		END
		IF NOT (@ROLE IS NULL) BEGIN
		IF  EXISTS (SELECT * FROM sys.database_principals WHERE [name] = @USER)
           BEGIN 
			IF @ADM=1 BEGIN
              EXEC sp_addrolemember [db_owner], @USER
              /*EXEC sp_addrolemember [db_accessadmin], @USER*/
			  EXEC ('master..sp_addsrvrolemember ['+@LOGIN+'], [securityadmin]');
            END ELSE EXEC sp_addrolemember @ROLE, @USER 
           END
		END
		IF @FIO = '-1' RETURN 
   	    IF  NOT EXISTS (SELECT * FROM dbo.Z_USER_LIST WHERE [LOGIN_NAME] = @LOGIN)
		BEGIN
			INSERT INTO  dbo.Z_USER_LIST ([LOGIN_NAME], [FIO]) VALUES (@LOGIN, @FIO)
		END

    END
END