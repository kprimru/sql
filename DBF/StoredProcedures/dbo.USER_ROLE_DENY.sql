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

CREATE PROCEDURE [dbo].[USER_ROLE_DENY]
	@user VARCHAR(100),
	@role VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

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
		EXEC sp_droprolemember @rolename, @user

		IF UPPER(@rolename) = 'RL_BULK'
		BEGIN			
			EXEC sp_dropsrvrolemember @loginname, 'bulkadmin'
		END
		ELSE IF UPPER(@rolename) = 'RL_USER'
		BEGIN
			EXEC sp_droprolemember 'db_accessadmin', @user
			EXEC sp_droprolemember 'db_securityadmin', @user

			EXEC sp_dropsrvrolemember @loginname, 'securityadmin'
		END

		FETCH NEXT FROM R INTO @rolename
	END

	CLOSE R
	DEALLOCATE R
	
	IF OBJECT_ID('tempdb..#role') IS NOT NULL
		DROP TABLE #role
	

END



