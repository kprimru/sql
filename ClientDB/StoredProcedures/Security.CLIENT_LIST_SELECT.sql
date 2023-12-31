USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[CLIENT_LIST_SELECT]
	@FILTER	VARCHAR(100)
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
			principal_id AS US_ID,
			1 AS RL,
			RoleStr,
			LST_RALL, LST_RMAN, LST_RSER, LST_RORI,
			LST_WALL, LST_WMAN, LST_WSER, LST_WORI
		FROM
			dbo.RoleTable
			INNER JOIN sys.database_principals ON name = RoleName
			INNER JOIN
			(
				SELECT
					LST_USER, LST_ALL AS LST_RALL, LST_ORI AS LST_RORI, LST_MANAGER AS LST_RMAN, LST_SERVICE AS LST_RSER
				FROM Security.ClientList
				WHERE LST_TYPE = 'READ'
			) AS r ON r.LST_USER = RoleName
			INNER JOIN
			(
				SELECT
					LST_USER, LST_ALL AS LST_WALL, LST_ORI AS LST_WORI, LST_MANAGER AS LST_WMAN, LST_SERVICE AS LST_WSER
				FROM Security.ClientList
				WHERE LST_TYPE = 'WRITE'
			) AS w ON w.LST_USER = RoleName
		WHERE @FILTER IS NULL
			OR RoleStr LIKE @FILTER
			OR RoleName LIKE @FILTER

		UNION ALL

		SELECT
			principal_id AS US_ID,
			2 AS RL,
			name AS RoleStr,
			LST_RALL, LST_RMAN, LST_RSER, LST_RORI,
			LST_WALL, LST_WMAN, LST_WSER, LST_WORI
		FROM
			sys.database_principals
			INNER JOIN
			(
				SELECT
					LST_USER, LST_ALL AS LST_RALL, LST_ORI AS LST_RORI, LST_MANAGER AS LST_RMAN, LST_SERVICE AS LST_RSER
				FROM Security.ClientList
				WHERE LST_TYPE = 'READ'
			) AS r ON r.LST_USER = name
			INNER JOIN
			(
				SELECT
					LST_USER, LST_ALL AS LST_WALL, LST_ORI AS LST_WORI, LST_MANAGER AS LST_WMAN, LST_SERVICE AS LST_WSER
				FROM Security.ClientList
				WHERE LST_TYPE = 'WRITE'
			) AS w ON w.LST_USER = name
		WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.RoleTable
					WHERE RoleName = name
				)
			AND
				(
					@FILTER IS NULL
					OR name LIKE @FILTER
				)
		ORDER BY RL, RoleStr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[CLIENT_LIST_SELECT] TO rl_security_client_list_r;
GO
