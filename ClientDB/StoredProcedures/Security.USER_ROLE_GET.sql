USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_ROLE_GET]
	@ID	INT
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

		SELECT
			b.name AS RL_NAME,
			CONVERT(BIT,
				(
					SELECT COUNT(*)
					FROM sys.database_role_members d
					WHERE d.role_principal_id = b.principal_id
						AND d.member_principal_id = @ID
				)
			) AS RL_SELECT
		FROM
			dbo.RoleTable a
			INNER JOIN sys.database_principals b ON name = RoleName
		ORDER BY RoleName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_ROLE_GET] TO rl_user_roles;
GO
