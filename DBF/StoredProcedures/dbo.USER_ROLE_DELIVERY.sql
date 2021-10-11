USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[USER_ROLE_DELIVERY]
	@sourceuser VARCHAR(100),
	@destuser VARCHAR(100)
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

		IF OBJECT_ID('tempdb..#sourceuser') IS NOT NULL
			DROP TABLE #sourceuser

		CREATE TABLE #sourceuser
			(
				UserName VARCHAR(100),
				GroupName VARCHAR(100),
				LoginName VARCHAR(100),
				DefDBName VARCHAR(100),
				DefSchemaName VARCHAR(100),
				UserID INT,
				SID VARBINARY(1000)
			)

		INSERT INTO #sourceuser
			EXEC sp_helpuser @sourceuser


		IF OBJECT_ID('tempdb..#destuser') IS NOT NULL
			DROP TABLE #Destuser

		CREATE TABLE #destuser
			(
				UserName VARCHAR(100),
				GroupName VARCHAR(100),
				LoginName VARCHAR(100),
				DefDBName VARCHAR(100),
				DefSchemaName VARCHAR(100),
				UserID INT,
				SID VARBINARY(1000)
			)

		INSERT INTO #destuser
			EXEC sp_helpuser @destuser

		DECLARE DROPROLE CURSOR LOCAL FOR
			SELECT GroupName
			FROM
				#destuser LEFT OUTER JOIN
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
				AND NOT EXISTS
					(
						SELECT GroupName
						FROM
							#sourceuser LEFT OUTER JOIN
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
					)

		DECLARE @rolename VARCHAR(100)

		OPEN DROPROLE

		FETCH NEXT FROM DROPROLE INTO @rolename

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--EXEC sp_droprolemember @rolename, @destuser

			FETCH NEXT FROM DROPROLE INTO @rolename
		END

		CLOSE DROPROLE
		DEALLOCATE DROPROLE



		DECLARE ADDROLE CURSOR LOCAL FOR
			SELECT GroupName
			FROM
				#sourceuser a LEFT OUTER JOIN
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
				AND NOT EXISTS
					(
						SELECT GroupName
						FROM
							#destuser b LEFT OUTER JOIN
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

							AND a.GroupName = b.GroupName
					)

		OPEN ADDROLE

		FETCH NEXT FROM ADDROLE INTO @rolename

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC sp_addrolemember @rolename, @destuser

			PRINT @rolename + ' ' + @destuser

			FETCH NEXT FROM ADDROLE INTO @rolename
		END

		CLOSE ADDROLE
		DEALLOCATE ADDROLE

		IF OBJECT_ID('tempdb..#sourceuser') IS NOT NULL
			DROP TABLE #sourceuser

		IF OBJECT_ID('tempdb..#destuser') IS NOT NULL
			DROP TABLE #destuser

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[USER_ROLE_DELIVERY] TO rl_admin_permission_w;
GO
