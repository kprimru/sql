USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BL_USER_DELETE]
	@USER varchar(128)
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
		IF (CHARINDEX('''', @USER) <> 0) 
		BEGIN
			SET @ERROR = 'Имя пользователя или роль содержат недоспустимые символы (кавычка)'

			RAISERROR (@ERROR, 16, 1)

			RETURN
		END
		EXEC('DROP USER [' + @USER +']')
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END