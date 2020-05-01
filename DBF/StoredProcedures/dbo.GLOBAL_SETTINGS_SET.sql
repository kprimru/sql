USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GLOBAL_SETTINGS_SET]
	@NAME	VARCHAR(50),
	@VALUE	VARCHAR(500)
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

		IF EXISTS(SELECT * FROM dbo.GlobalSettingsTable WHERE GS_NAME = @NAME)
			UPDATE dbo.GlobalSettingsTable
			SET GS_VALUE = @VALUE
			WHERE GS_NAME = @NAME
		ELSE
			INSERT INTO dbo.GlobalSettingsTable(GS_NAME, GS_VALUE, GS_ACTIVE)
				VALUES(@NAME, @VALUE, 1)
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
