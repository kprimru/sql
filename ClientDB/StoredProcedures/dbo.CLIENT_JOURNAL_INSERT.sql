USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_JOURNAL_INSERT]
	@CLIENT		INT,
	@JOURNAL	UNIQUEIDENTIFIER,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@NOTE		VARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.ClientJournal(ID_CLIENT, ID_JOURNAL, START, FINISH, NOTE)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@CLIENT, @JOURNAL, @BEGIN, @END, @NOTE)
		
	SELECT @ID = ID FROM @TBL
END
