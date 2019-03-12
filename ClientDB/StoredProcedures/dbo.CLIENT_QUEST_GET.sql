USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_QUEST_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientQuestionDate, QuestionID, AnswerID, ClientQuestionText, ClientQuestionComment
	FROM 
		dbo.ClientQuestionTable a
	WHERE ClientQuestionID = @ID
END