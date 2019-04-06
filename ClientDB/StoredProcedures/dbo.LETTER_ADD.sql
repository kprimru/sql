USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LETTER_ADD]
	@directory VARCHAR(100),
	@name VARCHAR(100),
	@data VARBINARY(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.LetterTable(LetterDirectory, LetterName, LetterData)
	VALUES (@directory, @name, @data)
END