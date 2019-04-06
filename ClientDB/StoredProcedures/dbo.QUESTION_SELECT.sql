USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[QUESTION_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT QuestionID, QuestionName, QuestionDate, QuestionFreeAnswer
	FROM dbo.QuestionTable a
	WHERE @FILTER IS NULL
		OR QuestionName LIKE @FILTER
		OR EXISTS
			(
				SELECT *
				FROM dbo.AnswerTable b
				WHERE a.QuestionID = b.QuestionID
					AND AnswerName LIKE @FILTER
			)
	ORDER BY QuestionName
END