USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Mailing].[WEB_MESSAGES_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PSEDO, TXT
	FROM Seminar.Messages
END
