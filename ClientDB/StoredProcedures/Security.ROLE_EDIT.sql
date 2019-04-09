USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[ROLE_EDIT]
	@RoleID			INT,
	@RoleMasterID	INT,
	@RoleName		VARCHAR(50),
	@RoleCaption	VARCHAR(50),
	@RoleNote		VARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OldName VARCHAR(50)

	SELECT @OldName = RoleName
	FROM	Security.Roles
	WHERE	RoleID = @RoleID

	IF @OldName <> @RoleName
	BEGIN
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
		
		EXEC ('ALTER ROLE [' + @OldName + '] WITH NAME = [' + @RoleName + ']')
	END

	UPDATE	Security.Roles
	SET		RoleName	=	@RoleName,
			RoleCaption	=	@RoleCaption,
			RoleMasterID	=	@RoleMasterID,
			RoleNote	=	@RoleNote
	WHERE	RoleID = @RoleID
END