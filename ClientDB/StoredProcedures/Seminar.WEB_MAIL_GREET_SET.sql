USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[WEB_MAIL_CONFIRM_SET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Seminar.Personal
	SET MSG_SEND = GETDATE()
	WHERE ID = @ID
END
