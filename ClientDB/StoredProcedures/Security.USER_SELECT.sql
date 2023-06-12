USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[USER_SELECT]
	@FILTER	VARCHAR(50) = NULL
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

		SELECT
			a.principal_id AS US_ID, 0 AS US_TYPE, name AS US_NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT RoleStr + ', '
					FROM
						dbo.RoleTable
						INNER JOIN sys.database_principals b ON b.name = RoleName
						INNER JOIN sys.database_role_members c ON c.role_principal_id = b.principal_id
					WHERE c.member_principal_id = a.principal_id
					ORDER BY RoleName FOR XML PATH('')
				)
			), 1, 2, '')) AS US_ROLE
		FROM sys.database_principals a
		WHERE Type IN ('S', 'U')
			AND name NOT IN
				(
					'INFORMATION_SCHEMA', 'dbo', 'guest', 'sys'
				)
			AND
				(
					@FILTER IS NULL
					OR a.name LIKE @FILTER
				)

		UNION ALL

		SELECT b.principal_id AS US_ID, 1 AS US_TYPE, RoleStr, ''
		FROM
			dbo.RoleTable
			INNER JOIN sys.database_principals b ON b.name = RoleName
		WHERE @FILTER IS NULL
			OR RoleStr LIKE @FILTER
			OR RoleName LIKE @FILTER
		ORDER BY US_TYPE, name

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_SELECT] TO rl_client_message_r;
GRANT EXECUTE ON [Security].[USER_SELECT] TO rl_user_r;
GRANT EXECUTE ON [Security].[USER_SELECT] TO rl_user_roles;
GO
