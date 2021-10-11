USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_EVENT_DELETE]
	@ID	INT
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

		INSERT INTO dbo.EventTable
			(
				ClientID, MasterID, EventDate, EventComment, EventTypeID, EventActive,
				EventCreate, EventLastUpdate, EventCreateUser, EventLastUpdateUser
			)
			SELECT
				ClientID, MasterID, EventDate, EventComment, EventTypeID, 0,
				EventCreate, GETDATE(), EventCreateUser, ORIGINAL_LOGIN()
			FROM dbo.EventTable
			WHERE EventID = @ID

		UPDATE dbo.EventTable
		SET EventActive = 0
		WHERE EventID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_EVENT_DELETE] TO rl_client_event_d;
GO
