USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_PANEL_USER_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_PANEL_USER_SET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[INFO_PANEL_USER_SET]
	@ID		UNIQUEIDENTIFIER,
	@USER	NVARCHAR(128),
	@STATE	BIT
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

		IF @STATE = 0
			DELETE
			FROM dbo.InfoPanelUser
			WHERE ID_PANEL = @ID AND USR_NAME = @USER
		ELSE
			INSERT INTO dbo.InfoPanelUser(ID_PANEL, USR_NAME)
				VALUES(@ID, @USER)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INFO_PANEL_USER_SET] TO rl_info_panel;
GO
