USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_TYPE_ACTUAL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_TYPE_ACTUAL]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[USER_TYPE_ACTUAL]
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

		SELECT UT_ROLE
		FROM
			Security.UserType
			INNER JOIN sys.database_principals a ON UT_ROLE = a.name
			INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
			INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
		WHERE c.name = ORIGINAL_LOGIN()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_TYPE_ACTUAL] TO public;
GO
