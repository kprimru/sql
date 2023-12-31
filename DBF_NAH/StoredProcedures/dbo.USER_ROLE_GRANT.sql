USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
�����:			������� �������/������ ��������
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[USER_ROLE_GRANT]
	@user VARCHAR(100),
	@role VARCHAR(MAX)
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

		IF OBJECT_ID('tempdb..#role') IS NOT NULL
			DROP TABLE #role

		CREATE TABLE #role
			(
				ROLE_NAME VARCHAR(100)
			)

		INSERT INTO #role
			SELECT * FROM dbo.GET_STRING_TABLE_FROM_LIST(@role, ',')

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
				EXEC sp_helpuser @user

		DECLARE @loginname VARCHAR(100)
		SELECT DISTINCT @loginname = LoginName FROM #user

		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user

		DECLARE R CURSOR LOCAL FOR
			SELECT a.ROLE_NAME
			FROM
				#role a INNER JOIN
				dbo.RoleTable b ON a.ROLE_NAME = b.ROLE_NAME

		DECLARE @rolename VARCHAR(100)

		OPEN R

		FETCH NEXT FROM R INTO @rolename

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC sp_addrolemember @rolename, @user

			IF UPPER(@rolename) = 'RL_BULK'
			BEGIN
				EXEC sp_addsrvrolemember @loginname, 'bulkadmin'
			END
			ELSE IF UPPER(@rolename) = 'RL_USER'
			BEGIN
				EXEC sp_addrolemember 'db_accessadmin', @user
				EXEC sp_addrolemember 'db_securityadmin', @user

				EXEC sp_addsrvrolemember @loginname, 'securityadmin'
			END

			FETCH NEXT FROM R INTO @rolename
		END

		CLOSE R
		DEALLOCATE R

		IF OBJECT_ID('tempdb..#role') IS NOT NULL
			DROP TABLE #role

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[USER_ROLE_GRANT] TO rl_user;
GO
