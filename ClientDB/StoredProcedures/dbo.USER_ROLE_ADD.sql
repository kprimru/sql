USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USER_ROLE_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USER_ROLE_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[USER_ROLE_ADD]
	@USER   VARCHAR(128),
	@ROLE	VARCHAR(128),
	@MODE	INT = 0,
	@ADM    INT = 0
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

		DECLARE @ERROR VARCHAR(MAX)
		IF (CHARINDEX('''', @USER) <> 0) OR
		   (CHARINDEX('''', @ROLE) <> 0)
		BEGIN
			SET @ERROR = 'Имя пользователя или роль содержат недоспустимые символы (кавычка)'

			RAISERROR (@ERROR, 16, 1)

			RETURN
		END
		IF @MODE = 0
		BEGIN
			EXEC sp_addrolemember @ROLE, @USER
			if @ADM =1 EXEC ('master..sp_addsrvrolemember ['+@USER+'], [securityadmin]');
		END
		ELSE BEGIN
			EXEC sp_droprolemember  @ROLE, @USER
			if @ADM =1 EXEC ('master..sp_dropsrvrolemember ['+@USER+'], [securityadmin]');
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[USER_ROLE_ADD] TO BL_ADMIN;
GO
