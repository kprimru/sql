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

ALTER PROCEDURE [dbo].[USER_CREATE]
	@domainname VARCHAR(100),
	@sqlname VARCHAR(100),
	@pass VARCHAR(100)
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
	
		IF @domainname IS NOT NULL
		BEGIN
			IF NOT EXISTS
				(
					SELECT * 
					FROM sys.server_principals 
					WHERE [NAME] = @domainname
						AND [TYPE_DESC] = 'WINDOWS_LOGIN'
				)
			BEGIN
				EXEC('CREATE LOGIN [' + @domainname + '] FROM WINDOWS')	
			END
			
			IF NOT EXISTS
				(
					SELECT * 
					FROM sys.database_principals 
					WHERE TYPE_DESC = 'WINDOWS_USER' 
						AND [NAME] = @domainname
				)
			BEGIN
				EXEC('CREATE USER [' + @domainname +'] FOR LOGIN [' + @domainname + ']')
			END

			SELECT @domainname AS [USER_NAME]
		END
		ELSE 
		BEGIN
			IF NOT EXISTS
				(
					SELECT * 
					FROM sys.server_principals 
					WHERE [NAME] = @sqlname
						AND [TYPE_DESC] = 'SQL_LOGIN'
				)
			BEGIN
				EXEC('CREATE LOGIN [' + @sqlname + '] WITH PASSWORD = ''' + @pass + ''', CHECK_POLICY = OFF')	
			END

			IF NOT EXISTS
				(
					SELECT * 
					FROM sys.database_principals 
					WHERE TYPE_DESC = 'SQL_USER' 
						AND [NAME] = @sqlname
				)
			BEGIN
				EXEC('CREATE USER [' + @sqlname +'] FOR LOGIN [' + @sqlname + ']')
			END

			SELECT @sqlname AS [USER_NAME]
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[USER_CREATE] TO rl_user;
GO