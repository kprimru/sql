USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTROL_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTROL_EDIT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CONTROL_EDIT]
	@CC_ID	INT,
	@TEXT	VARCHAR(MAX)
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

		UPDATE dbo.ClientControl
		SET CC_TEXT = @TEXT
		WHERE CC_ID = @CC_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTROL_EDIT] TO rl_client_control_chief_set;
GRANT EXECUTE ON [dbo].[CONTROL_EDIT] TO rl_client_control_duty_set;
GRANT EXECUTE ON [dbo].[CONTROL_EDIT] TO rl_client_control_lawyer_set;
GRANT EXECUTE ON [dbo].[CONTROL_EDIT] TO rl_client_control_manager_set;
GRANT EXECUTE ON [dbo].[CONTROL_EDIT] TO rl_client_control_quality_set;
GO
