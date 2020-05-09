USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[USER_ROLE_SELECT]
	@username VARCHAR(100)
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

		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user

		CREATE TABLE #user
			(
				UserName VARCHAR(100),
				GroupName VARCHAR(100),
				LoginName VARCHAR(100),
				DefDBName VARCHAR(100),
				DefSchemaName VARCHAR(100),
				UserID INT,
				SID VARBINARY(1000)
			)

		INSERT INTO #user
			EXEC sp_helpuser @username

		SELECT 1 AS HasRole, GroupName, ROLE_NOTE
		FROM
			#user LEFT OUTER JOIN
			dbo.RoleTable ON ROLE_NAME = GroupName
		WHERE GroupName <> 'public'
			AND GroupName <> 'db_accessadmin'
			AND GroupName <> 'db_securityadmin'
			AND GroupName <> 'db_backupoperator'
			AND GroupName <> 'db_datareader'
			AND GroupName <> 'db_datawriter'
			AND GroupName <> 'db_securityadmin'
			AND GroupName <> 'db_ddladmin'
			AND GroupName <> 'db_denydatareader'
			AND GroupName <> 'db_denydatawriter'
			AND GroupName <> 'db_owner'

		UNION ALL

		SELECT 0 AS HasRole, ROLE_NAME, ROLE_NOTE
		FROM dbo.RoleTable
		WHERE NOT EXISTS(SELECT * FROM #user WHERE GroupName = ROLE_NAME)
			AND ROLE_NAME <> 'public'
			AND ROLE_NAME <> 'db_accessadmin'
			AND ROLE_NAME <> 'db_securityadmin'
			AND ROLE_NAME <> 'db_backupoperator'
			AND ROLE_NAME <> 'db_datareader'
			AND ROLE_NAME <> 'db_datawriter'
			AND ROLE_NAME <> 'db_securityadmin'
			AND ROLE_NAME <> 'db_ddladmin'
			AND ROLE_NAME <> 'db_denydatareader'
			AND ROLE_NAME <> 'db_denydatawriter'
			AND ROLE_NAME <> 'db_owner'
		ORDER BY GroupName

		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[USER_ROLE_SELECT] TO rl_user;
GO