USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLES_ACTUAL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLES_ACTUAL]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLES_ACTUAL]
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

		SELECT a.name
		FROM
			sys.database_principals a
			INNER JOIN sys.database_role_members b ON b.role_principal_id = a.principal_id
			INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
		WHERE c.name = ORIGINAL_LOGIN()

		UNION ALL

		SELECT e.name
		FROM
			sys.database_principals a
			INNER JOIN sys.database_role_members b ON b.member_principal_id = a.principal_id
			INNER JOIN sys.database_principals c ON b.role_principal_id = c.principal_id
			INNER JOIN sys.database_role_members d ON d.member_principal_id = c.principal_id
			INNER JOIN sys.database_principals e ON d.role_principal_id = e.principal_id
		WHERE a.name = ORIGINAL_LOGIN()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLES_ACTUAL] TO public;
GO
