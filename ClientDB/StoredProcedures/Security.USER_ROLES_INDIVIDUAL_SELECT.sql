USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[USER_ROLES_INDIVIDUAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[USER_ROLES_INDIVIDUAL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[USER_ROLES_INDIVIDUAL_SELECT]
	@USER	VARCHAR(50) = NULL
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
			[UserName]	= u.name,
			[Role]		= r.name,
			G.GroupName,
			SR.RoleCaption
		FROM sys.database_principals r
		INNER JOIN sys.database_role_members rm ON r.principal_id = rm.role_principal_id
		INNER JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
		OUTER APPLY
		(
			SELECT [GroupName] = String_Agg(RT.RoleStr, ',')
			FROM sys.database_role_members AS grm
			INNER JOIN sys.database_principals AS gr ON gr.principal_id = grm.role_principal_id
			INNER JOIN dbo.RoleTable AS RT ON RT.RoleName = gr.name
			WHERE grm.member_principal_id = u.principal_id
				AND gr.name LIKE 'DB%'
		) AS G
		OUTER APPLY
		(
			SELECT TOP (1) SR.RoleCaption
			FROM Security.RoleTreeView AS SR
			WHERE SR.RoleName = r.name
		) AS SR
		WHERE u.type <> 'R' AND r.name like 'rl_%'
			AND u.name = @USER OR @USER IS NULL
		ORDER BY r.name, u.name

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_ROLES_INDIVIDUAL_SELECT] TO rl_user_roles;
GO
