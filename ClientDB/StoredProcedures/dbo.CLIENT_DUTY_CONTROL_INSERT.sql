USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_CONTROL_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_INSERT]
	@CALL	UNIQUEIDENTIFIER,
	@ANSWER	TINYINT,
	@SATISF	TINYINT,
	@NOTE	NVARCHAR(MAX)
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

		INSERT INTO dbo.ClientDutyControl(CDC_ID_CALL, CDC_ANSWER, CDC_SATISF, CDC_NOTE)
			VALUES(@CALL, @ANSWER, @SATISF, @NOTE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_CONTROL_INSERT] TO rl_duty_control;
GO
