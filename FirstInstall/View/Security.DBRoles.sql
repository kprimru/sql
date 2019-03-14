USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Security].[DBRoles] 
--WITH SCHEMABINDING
AS
	SELECT [name] AS ROLE_NAME, create_date AS ROLE_CREATE
	FROM sys.database_principals
	WHERE [type] = 'R'
		AND [name] NOT IN
			(
				'public', 'db_owner', 'db_accessadmin',
				'db_securityadmin', 'db_ddladmin',
				'db_backupoperator', 'db_datareader',
				'db_datawriter', 'db_denydatareader',
				'db_denydatawriter'
			)