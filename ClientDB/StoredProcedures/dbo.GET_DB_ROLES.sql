USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_DB_ROLES]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_DB_ROLES]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[GET_DB_ROLES]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT DbRole = b.name, MemberName = d.name, MemberSID = d.sid
		FROM
			dbo.RoleTable a
			INNER JOIN sys.database_principals b ON a.RoleName = b.name
			INNER JOIN sys.database_role_members c ON b.principal_id = c.role_principal_id
			INNER JOIN sys.database_principals d ON d.principal_id = c.member_principal_id
		WHERE b.Name <> 'DBStatistic' /*AND d.name = ORIGINAL_LOGIN()*/
		ORDER BY d.Name

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_DB_ROLES] TO public;
GO
