USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[GLOBAL_SETTINGS_EDIT]
	@gsid SMALLINT,
	@gsname VARCHAR(50),
	@gsvalue VARCHAR(50),
	@active BIT = 1
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

		UPDATE dbo.GlobalSettingsTable
		SET
			GS_NAME = @gsname,
			GS_VALUE = @gsvalue,
			GS_ACTIVE = @active
		WHERE GS_ID = @gsid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GLOBAL_SETTINGS_EDIT] TO rl_global_settings_w;
GO
