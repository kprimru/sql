USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_MESSAGE_SENDER_SELECT]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT SENDER
	FROM dbo.ClientMessage
	WHERE STATUS = 1 AND HARD_READ = 1
	ORDER BY SENDER
END
