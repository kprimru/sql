USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LETTER_SELECT]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LetterID, LetterDirectory, LetterName/*, LetterData*/
	FROM dbo.LetterTable
	ORDER BY LetterDirectory, LetterName
END