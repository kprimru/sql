USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [IP].[CLIENT_CONS_INET_LOG]
	@FILE	NVARCHAR(512)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT REPLACE(LF_TEXT, CHAR(10), CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13)) AS LF_TEXT
	FROM IP.LogFileView
	WHERE FL_NAME = @FILE
END
