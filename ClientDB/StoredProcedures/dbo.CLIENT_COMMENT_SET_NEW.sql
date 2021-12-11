USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_COMMENT_SET_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_COMMENT_SET_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_COMMENT_SET_NEW]
	@ID			INT
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

		UPDATE dbo.ClientTable
		SET
			ClientLastUpdate = GETDATE()
		WHERE ClientID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_COMMENT_SET_NEW] TO rl_client_search_comment;
GRANT EXECUTE ON [dbo].[CLIENT_COMMENT_SET_NEW] TO rl_client_search_import;
GO
