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

CREATE PROCEDURE [dbo].[USER_GROUP_EDIT]
	@groupname VARCHAR(100),	
	@groupnote VARCHAR(500),
	@grouproles VARCHAR(MAX)
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

		IF OBJECT_ID('tempdb.#role') IS NOT NULL
			DROP TABLE #role

		CREATE TABLE #role
			(
				RL_NAME VARCHAR(100)
			)

		INSERT INTO #role
			SELECT * FROM dbo.GET_STRING_TABLE_FROM_LIST(@grouproles, ',')

		IF NOT EXISTS
			(
				SELECT * 
				FROM sys.database_principals
				WHERE TYPE_DESC = 'DATABASE_ROLE' AND [NAME] = @groupname
			)
		BEGIN
			EXEC('CREATE ROLE ' + @groupname)

			INSERT INTO dbo.RoleTable(ROLE_NAME, ROLE_NOTE)
				SELECT @groupname, @groupnote
		END

		DECLARE @rolename VARCHAR(100)
		DECLARE ROLES CURSOR LOCAL FOR
			SELECT RL_NAME
			FROM #role

		FETCH NEXT FROM ROLES INTO @rolename

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXEC sp_addrolemember @rolename, @groupname

			FETCH NEXT FROM ROLES INTO @rolename
		END

		IF OBJECT_ID('tempdb.#role') IS NOT NULL
			DROP TABLE #role
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
