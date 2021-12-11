USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTROL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTROL_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_GET]
	@CLIENT	INT
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

		SELECT TOP 1 CC_ID, CC_TEXT, CC_AUTHOR, CC_DATE
		FROM dbo.ClientControl
		WHERE CC_ID_CLIENT = @CLIENT
			AND CC_READ_DATE IS NULL
			AND CC_REMOVE_DATE IS NULL
			AND (CC_BEGIN IS NULL OR CC_BEGIN <= GETDATE())
		ORDER BY CC_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_GET] TO rl_client_control_read;
GO
