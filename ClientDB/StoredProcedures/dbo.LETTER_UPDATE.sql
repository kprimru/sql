USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LETTER_UPDATE]
	@id INT,
	@directory VARCHAR(100),
	@name VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.LetterTable
	SET LetterDirectory = @directory, 
		LetterName = @name
	WHERE LetterID = @id
END