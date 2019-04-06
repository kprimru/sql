USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_QUESTION_SELECT]	
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientQuestionID, QuestionName, QuestionDate, 
		QuestionDate AS QuestionDateStr, 
		a.AnswerID, AnswerName, ClientQuestionComment,
		CONVERT(VARCHAR(20), CONVERT(DATETIME, ClientQuestionDate, 112), 104) AS ClientQuestionDate,
		CONVERT(VARCHAR(50), ClientQuestionCreateDate, 104) + ' ' + CONVERT(VARCHAR(50), ClientQuestionCreateDate, 114) + ' / ' + ClientQuestionCreateUser AS ClientQuestionCreate,
		CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 104) + '  ' + CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 114) + ' / ' + ClientQuestionLastUpdateUser AS ClientQuestionLastUpdate
	FROM 
		dbo.ClientQuestionTable	a INNER JOIN
		dbo.QuestionTable b ON a.QuestionID = b.QuestionID INNER JOIN
		dbo.AnswerTable c ON c.AnswerID = a.AnswerID
	WHERE ClientID = @clientid	
		AND a.AnswerID IS NOT NULL

	UNION ALL

	SELECT 
		ClientQuestionID, QuestionName, QuestionDate, 
		QuestionDate AS QuestionDateStr, 
		NULL AS AsnwerID, ClientQuestionText, ClientQuestionComment,
		CONVERT(VARCHAR(20), CONVERT(DATETIME, ClientQuestionDate, 112), 104) AS ClientQuestionDate,
		CONVERT(VARCHAR(50), ClientQuestionCreateDate, 104) + ' ' + CONVERT(VARCHAR(50), ClientQuestionCreateDate, 114) + ' / ' + ClientQuestionCreateUser AS ClientQuestionCreate,
		CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 104) + '  ' + CONVERT(VARCHAR(50), ClientQuestionLastUpdate, 114) + ' / ' + ClientQuestionLastUpdateUser AS ClientQuestionLastUpdate
	FROM 
		dbo.ClientQuestionTable a INNER JOIN
		dbo.QuestionTable b ON a.QuestionID = b.QuestionID
	WHERE ClientID = @clientid	
		AND a.AnswerID IS NULL
	ORDER BY QuestionDate DESC
END