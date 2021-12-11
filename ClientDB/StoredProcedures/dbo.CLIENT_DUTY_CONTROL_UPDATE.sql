USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_CONTROL_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_UPDATE]
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

		UPDATE dbo.ClientDutyControl
		SET CDC_ANSWER	=	@ANSWER,
			CDC_SATISF	=	@SATISF,
			CDC_NOTE	=	@NOTE
		WHERE CDC_ID_CALL = @CALL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_CONTROL_UPDATE] TO rl_duty_control;
GO
