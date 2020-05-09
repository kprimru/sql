USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_HIDE]
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

		INSERT INTO dbo.ClientMessage(ID_MASTER, ID_CLIENT, TP, SENDER, DATE, NOTE, RECEIVE_USER, RECEIVE_DATE, RECEIVE_HOST, HARD_READ, DELAY_MIN, REMIND_DATE, HIDE, STATUS, UPD_DATE, UPD_USER)
			SELECT ID, ID_CLIENT, TP, SENDER, DATE, NOTE, RECEIVE_USER, RECEIVE_DATE, RECEIVE_HOST, HARD_READ, DELAY_MIN, REMIND_DATE, HIDE, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientMessage
			WHERE ID = @ID

		UPDATE dbo.ClientMessage
		SET HIDE = 1,
			UPD_USER = ORIGINAL_LOGIN(),
			UPD_DATE = GETDATE()
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
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_HIDE] TO rl_client_message_r;
GO