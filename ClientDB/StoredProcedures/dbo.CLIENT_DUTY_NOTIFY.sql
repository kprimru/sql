USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DUTY_NOTIFY]
	@DUTY			INT,
	@NOTIFY			TINYINT,
	@NOTIFY_NOTE	NVARCHAR(MAX),
	@NOTIFY_TYPE	TINYINT
AS
BEGIN
	SET NOCOUNT ON;

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
END
