USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DUTY_CONTROL_DELETE]
	@CALL	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.ClientDutyControl
	WHERE CDC_ID_CALL = @CALL
END
