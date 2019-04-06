USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_QUESTION_UPDATE]
	@id INT,
	@questionid INT,
	@answerid INT,
	@text VARCHAR(150),
	@date SMALLDATETIME,
	@COMMENT	VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientQuestionTable
	SET QuestionID = @questionid, 
		AnswerID = @answerid, 
		ClientQuestionText = @text, 
		ClientQuestionDate = @date,
		ClientQuestionComment = @COMMENT,
		ClientQuestionLastUpdate = GETDATE(),
		ClientQuestionLastUpdateUser = ORIGINAL_LOGIN()
	WHERE ClientQuestionID = @id	
END