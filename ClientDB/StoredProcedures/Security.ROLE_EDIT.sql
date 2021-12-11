USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_EDIT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_EDIT]
	@RoleID			INT,
	@RoleMasterID	INT,
	@RoleName		VARCHAR(50),
	@RoleCaption	VARCHAR(50),
	@RoleNote		VARCHAR(MAX)
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_EDIT] TO rl_role_u;
GO
