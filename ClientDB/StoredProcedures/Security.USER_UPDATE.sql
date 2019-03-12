USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[USER_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@ROLES	VARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD_NAME	VARCHAR(50)

	SELECT @OLD_NAME = name
	FROM sys.database_principals
	WHERE principal_id = @ID

	
	IF @OLD_NAME <> @NAME
	BEGIN
		EXEC('ALTER LOGIN [' + @OLD_NAME + '] WITH NAME = [' + @NAME + ']')
		EXEC('ALTER USER [' + @OLD_NAME + '] WITH NAME = [' + @NAME + ']')
	END

	DECLARE RL_DROP CURSOR LOCAL FOR
		SELECT RoleName
		FROM 
			dbo.RoleTable a
			INNER JOIN sys.database_principals b ON a.RoleName = b.name
			INNER JOIN sys.database_role_members c ON c.role_principal_id = b.principal_id
		WHERE c.member_principal_id = @ID
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.TableStringFromXML(@ROLES)
					WHERE ID = a.RoleName
				)

	OPEN RL_DROP
	
	DECLARE @RL	VARCHAR(50)

	FETCH NEXT FROM RL_DROP INTO @RL

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXEC sp_droprolemember @RL, @NAME

		FETCH NEXT FROM RL_DROP INTO @RL
	END

	CLOSE RL_DROP
	DEALLOCATE RL_DROP

	DECLARE RL_ADD CURSOR LOCAL FOR
		SELECT ID
		FROM dbo.TableStringFromXML(@ROLES)
		WHERE 
			NOT EXISTS
				(
					SELECT *
					FROM 
						dbo.RoleTable a
						INNER JOIN sys.database_principals b ON a.RoleName = b.name
						INNER JOIN sys.database_role_members c ON c.role_principal_id = b.principal_id
					WHERE ID = a.RoleName AND c.member_principal_id = @ID
				)

	OPEN RL_ADD
	
	FETCH NEXT FROM RL_ADD INTO @RL

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXEC sp_addrolemember @RL, @NAME

		FETCH NEXT FROM RL_ADD INTO @RL
	END

	CLOSE RL_ADD
	DEALLOCATE RL_ADD
END