USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_EVENT_UPDATE]
	@ID			INT,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@TYPE		INT,
	@COMMENT	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TXT NVARCHAR(1024)

	SET @TXT = ''

	IF (IS_MEMBER('rl_client_event_limit') = 1) AND (@DATE <> (SELECT EventDate FROM dbo.EventTable WHERE EventID = @ID))
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
END