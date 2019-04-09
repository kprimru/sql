USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EVENT_INSERT]
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@TYPE		INT,
	@COMMENT	VARCHAR(MAX),
	@ID			INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TXT NVARCHAR(1024)

	SET @TXT = ''

	IF IS_MEMBER('rl_client_event_limit') = 1
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

	INSERT INTO dbo.EventTable(ClientID, EventDate, EventTypeID, EventComment)
		VALUES(@CLIENT, @DATE, @TYPE, @COMMENT)

	SELECT @ID = SCOPE_IDENTITY()

	UPDATE dbo.EventTable
	SET MasterID = @ID
	WHERE EventID = @ID
END