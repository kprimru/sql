USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_QUESTION_ADD]
	@clientid INT,
	@questionid INT,
	@answerid INT,
	@text VARCHAR(150),
	@date SMALLDATETIME,
	@COMMENT	VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientQuestionTable(
				ClientID, QuestionID, AnswerID, 
				ClientQuestionText, ClientQuestionDate,
				ClientQuestionComment,
				ClientQuestionLastUpdate, ClientQuestionLastUpdateUser)
	VALUES (@clientid, @questionid, @answerid, @text, @date, @COMMENT, GETDATE(), ORIGINAL_LOGIN())
END