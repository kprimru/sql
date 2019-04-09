USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ANSWER_GET]
	@question INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AnswerID, AnswerName
	FROM dbo.AnswerTable
	WHERE QuestionID = @question
	ORDER BY AnswerName
END