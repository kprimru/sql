USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[QUESTION_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT QuestionName, QuestionDate, QuestionFreeAnswer
	FROM dbo.QuestionTable a
	WHERE QuestionID = @ID
END