USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_EVENT_INSERT]
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@TYPE		INT,
	@COMMENT	VARCHAR(MAX),
	@ID			INT = NULL OUTPUT
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

		IF IS_MEMBER('rl_client_event_limit') = 1
		BEGIN
			IF @DATE < DATEADD(DAY, -7, dbo.DateOf(GETDATE()))
				SET @TXT = '������ ������ ���� ��������� ������, ��� 7 ���� � ���������� �������'
			IF @DATE > dbo.DateOf(GETDATE())
				SET @TXT = '������ ������ ���� ��������� ����� �������'

			IF @TXT <> ''
			BEGIN
				RAISERROR (@TXT, 16, 1)

				RETURN
			END
		END

		INSERT INTO dbo.EventTable(ClientID, EventDate, EventTypeID, EventComment)
			VALUES(@CLIENT, @DATE, @TYPE, @COMMENT)

		SELECT @ID = SCOPE_IDENTITY()

		UPDATE dbo.EventTable
		SET MasterID = @ID
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
GRANT EXECUTE ON [dbo].[CLIENT_EVENT_INSERT] TO rl_client_event_i;
GO
