﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_PANEL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_PANEL_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[INFO_PANEL_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT TEXT, DETAIL
		FROM dbo.InfoPanel
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
GRANT EXECUTE ON [dbo].[INFO_PANEL_GET] TO rl_info_panel;
GO
