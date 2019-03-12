USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[_QUESTION_SELECT]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		QuestionID, QuestionName, 
		Convert(VARCHAR(20), CONVERT(DATETIME, QuestionDate, 112), 104) AS QuestionDateStr, QuestionFreeAnswer
	FROM dbo.QuestionTable
	ORDER BY QuestionDate DESC
END
