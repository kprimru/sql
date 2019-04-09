USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[QUESTION_ANSWER_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AnswerID, QuestionID, AnswerName
	FROM dbo.AnswerTable
	WHERE QuestionID = @ID
	ORDER BY AnswerName
END