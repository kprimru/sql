USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[INFO_PANEL_USER_GET]
	@PANEL	UNIQUEIDENTIFIER
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

		SELECT
			US_ID, US_SQL_NAME, US_NAME, US_USER,
			CONVERT(BIT, CASE WHEN EXISTS
				(
					SELECT *
					FROM dbo.InfoPanelUser
					WHERE ID_PANEL = @PANEL
						AND USR_NAME = US_SQL_NAME
				) THEN 1
				ELSE 0
			END) AS CHECKED
		FROM Security.UserView a
		ORDER BY US_USER, US_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INFO_PANEL_USER_GET] TO rl_info_panel;
GO