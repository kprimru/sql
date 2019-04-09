USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Mailing].[REQUEST_SEND]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Mailing.Requests
	SET SendDate = GetDAte()
	WHERE Id = @ID
		AND SendDate IS NULL
END
