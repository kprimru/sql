USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_ADD]
	@RoleID			INT,
	@RoleName		VARCHAR(50),
	@RoleCaption	VARCHAR(50),
	@RoleNote		VARCHAR(MAX),
	@Id				Int = NULL OUT
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

		SET @Id = Scope_Identity();

		IF @RoleName IS NOT NULL AND @RoleName != ''
			EXEC ('CREATE ROLE ' + @RoleName)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_ADD] TO rl_role_i;
GO
