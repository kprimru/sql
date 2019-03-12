USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_QUEST_UPDATE]
	@ID	INT,
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@QUEST	INT,
	@ANS	INT,
	@TEXT	VARCHAR(150),
	@COMMENT	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	dbo.ClientQuestionTable 
	SET	QuestionID = @QUEST,
		ClientQuestionDate = @DATE,
		AnswerID = @ANS,
		ClientQuestionText = @TEXT,
		ClientQuestionComment = @COMMENT,
		ClientQuestionLastUpdate = GETDATE(),
		ClientQuestionLastUpdateUser = ORIGINAL_LOGIN()
	WHERE ClientQuestionID = @ID
END