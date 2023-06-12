USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_USERS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_USERS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_USERS_SELECT]
	@ROLE	NVARCHAR(128)
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

		SELECT US_NAME AS UserName, US_SQL_NAME AS UserRoleName, US_USER AS IsUser,
			CONVERT(BIT,
				CASE
					WHEN o_O.[name] IS NULL THEN 0
					ELSE 1
				END
			) AS UserSelect
		FROM
			Security.UserView a
			LEFT OUTER JOIN
				(
					SELECT c.name
					FROM
						sys.database_principals a
						INNER JOIN sys.database_role_members b ON b.role_principal_id = a.principal_id
						INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
					WHERE a.name = @ROLE
				) AS o_O ON US_SQL_NAME = name
		ORDER BY US_USER, US_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_USERS_SELECT] TO rl_user_roles;
GO
