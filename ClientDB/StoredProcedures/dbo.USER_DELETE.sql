USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USER_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USER_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[USER_DELETE]
	@USER varchar(128),
	@LOGIN varchar(128)
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

		DELETE FROM dbo.Z_USER_LIST	WHERE [LOGIN_NAME] = @LOGIN

		EXEC('DROP USER [' + @USER +']')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
