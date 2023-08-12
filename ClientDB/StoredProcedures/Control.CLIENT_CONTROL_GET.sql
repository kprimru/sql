USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Control].[CLIENT_CONTROL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Control].[CLIENT_CONTROL_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Control].[CLIENT_CONTROL_GET]
	@ID UNIQUEIDENTIFIER
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

		SELECT NOTE, NOTIFY, ID_GROUP, REMOVE_GROUP, REMOVE_AUTHOR, RECEIVER
		FROM Control.ClientControl
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_GET] TO rl_control_u;
GO
