USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_EVENT_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_EVENT_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_EVENT_UPDATE]
	@ID			INT,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@TYPE		INT,
	@COMMENT	VARCHAR(MAX)
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

		DECLARE @TXT NVARCHAR(1024)

		SET @TXT = ''

		IF (IS_MEMBER('rl_client_event_limit') = 1) AND (@DATE <> (SELECT EventDate FROM dbo.EventTable WHERE EventID = @ID))
		BEGIN
			IF @DATE < DATEADD(DAY, -7, dbo.DateOf(GETDATE()))
				SET @TXT = 'Нельзя ввести дату посещения раньше, чем 7 дней с настоящего момента'
			IF @DATE > dbo.DateOf(GETDATE())
				SET @TXT = 'Нельзя ввести дату посещения позже текущей'

			IF @TXT <> ''
			BEGIN
				RAISERROR (@TXT, 16, 1)

				RETURN
			END
		END

		INSERT INTO dbo.EventTable
			(
				ClientID, MasterID, EventDate, EventComment, EventTypeID,
				EventCreate, EventLastUpdate, EventCreateUser, EventLastUpdateUser
			)
			SELECT
				@CLIENT, MasterID, @DATE, @COMMENT, @TYPE,
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
GRANT EXECUTE ON [dbo].[CLIENT_EVENT_UPDATE] TO rl_client_event_u;
GO
