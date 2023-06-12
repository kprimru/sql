USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_NAMES_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_NAMES_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_NAMES_SAVE]
	@CLIENT		INT,
	@NAME		VARCHAR(500)
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

		INSERT INTO dbo.ClientNames(ID_CLIENT, NAME)
			VALUES(@CLIENT, @NAME)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_NAMES_SAVE] TO rl_client_save;
GO
