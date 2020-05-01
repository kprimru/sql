USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_SELECT]
	@SearchString	VARCHAR(100) = NULL
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

		IF OBJECT_ID('tempdb..#temprole') IS NOT NULL
			DROP TABLE #temprole

		CREATE TABLE #temprole
			(
				RoleID INT,
				RoleMasterID INT
			)

		IF @SearchString IS NOT NULL
		BEGIN
			INSERT INTO #temprole(RoleID, RoleMasterID)
				SELECT RoleID, RoleMasterID
				FROM Security.Roles
				WHERE RoleName IS NOT NULL AND
					(
						(RoleCaption LIKE @SearchString)
						OR (RoleName LIKE @SearchString)
						OR (RoleNote LIKE @SearchString)
					)

			WHILE EXISTS
				(
					SELECT *
					FROM
						Security.Roles a INNER JOIN
						#temprole b ON b.RoleMasterID = a.RoleID
					WHERE a.RoleMasterID IS NOT NULL AND a.RoleMasterID NOT IN
						(
							SELECT RoleID
							FROM #temprole
						)
				)
			BEGIN
				INSERT INTO #temprole(RoleID, RoleMasterID)
					SELECT a.RoleID, a.RoleMasterID
					FROM
						Security.Roles a INNER JOIN
						#temprole b ON b.RoleMasterID = a.RoleID
			END
		END
		ELSE
			INSERT INTO #temprole(RoleID, RoleMasterID)
				SELECT RoleID, RoleMasterID
				FROM Security.Roles

		SELECT a.RoleID, RoleMasterID, RoleName, RoleCaption, RoleNote
		FROM
			Security.Roles a INNER JOIN
			(
				SELECT DISTINCT RoleID
				FROM #temprole
			) AS o_O ON a.RoleID = o_O.RoleID
		ORDER BY RoleCaption

		IF OBJECT_ID('tempdb..#temprole') IS NOT NULL
			DROP TABLE #temprole

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Security].[ROLE_SELECT] TO rl_role_r;
GO