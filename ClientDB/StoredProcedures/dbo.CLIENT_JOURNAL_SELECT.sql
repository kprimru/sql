USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_JOURNAL_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.ID, b.NAME, START, FINISH, NOTE, UPD_DATE, UPD_USER
	FROM 
		dbo.ClientJournal a
		INNER JOIN dbo.Journal b ON a.ID_JOURNAL = b.ID
	WHERE ID_CLIENT = @ID AND STATUS = 1
	ORDER BY FINISH DESC
END
