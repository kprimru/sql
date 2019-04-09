USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[QUESTION_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@DATE	SMALLDATETIME,
	@FREE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.QuestionTable
	SET QuestionName = @NAME,
		QuestionDate = @DATE,
		QuestionFreeAnswer = @FREE,
		QuestionLast = GETDATE()
	WHERE QuestionID = @ID
END