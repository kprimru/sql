USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[ROLE_ADD]
	@RoleID			INT,
	@RoleName		VARCHAR(50),
	@RoleCaption	VARCHAR(50),
	@RoleNote		VARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT *
			FROM sys.database_principals
			WHERE Name = @RoleName
		)
	BEGIN
		DECLARE @ERROR VARCHAR(MAX)		
		
		SET @ERROR = 'Пользователь или роль "' + @RoleName + '" уже существуют в базе данных'
		
		RAISERROR (@ERROR, 16, 1)

		RETURN
	END

	INSERT INTO Security.Roles (RoleMasterID, RoleName, RoleCaption, RoleNote)
		VALUES(@RoleID, @RoleName, @RoleCaption, @RoleNote)

	IF @RoleName IS NOT NULL
		EXEC ('CREATE ROLE ' + @RoleName)
END