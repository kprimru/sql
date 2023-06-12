USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_NOTIFY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_NOTIFY]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_NOTIFY]
	@DUTY			INT,
	@NOTIFY			TINYINT,
	@NOTIFY_NOTE	NVARCHAR(MAX),
	@NOTIFY_TYPE	TINYINT
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

		DECLARE @ID UNIQUEIDENTIFIER

		SELECT @ID = ID
		FROM dbo.ClientDutyNotify
		WHERE ID_DUTY = @DUTY

		IF @ID IS NULL
			INSERT INTO dbo.ClientDutyNotify(ID_DUTY, NOTIFY, NOTIFY_NOTE, NOTIFY_TYPE)
				VALUES(@DUTY, @NOTIFY, @NOTIFY_NOTE, @NOTIFY_TYPE)
		ELSE
			UPDATE dbo.ClientDutyNotify
			SET NOTIFY = @NOTIFY,
				NOTIFY_NOTE = @NOTIFY_NOTE,
				NOTIFY_TYPE = @NOTIFY_TYPE
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
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_NOTIFY] TO rl_client_duty_result;
GO
