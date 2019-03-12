USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_INSERT]
	@CALL	UNIQUEIDENTIFIER,
	@ANSWER	TINYINT,
	@SATISF	TINYINT,
	@NOTE	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientDutyControl(CDC_ID_CALL, CDC_ANSWER, CDC_SATISF, CDC_NOTE)
		VALUES(@CALL, @ANSWER, @SATISF, @NOTE)
END
