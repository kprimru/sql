USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_DELETE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Security].[ROLE_DELETE]
	@RoleID			INT
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

		DECLARE RL CURSOR LOCAL FOR
			SELECT RoleID
			FROM Security.Roles
			WHERE RoleMasterID = @RoleID

		OPEN RL

		DECLARE @RL INT

		FETCH NEXT FROM RL INTO @RL

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC Security.ROLE_DELETE @RL

			FETCH NEXT FROM RL INTO @RL
		END

		CLOSE RL
		DEALLOCATE RL

		DECLARE @RoleName VARCHAR(50)

		SELECT @RoleName = RoleName
		FROM Security.Roles
		WHERE RoleID = @RoleID

		DELETE FROM Security.Roles
		WHERE RoleID = @RoleID

		IF @RoleName IS NOT NULL AND @RoleName != ''
			EXEC('DROP ROLE [' + @RoleName + ']')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_DELETE] TO rl_role_d;
GO
