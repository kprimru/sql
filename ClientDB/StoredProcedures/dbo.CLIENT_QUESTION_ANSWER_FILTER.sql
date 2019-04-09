USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_QUESTION_ANSWER_FILTER]
	@questionid INT,
	@serviceid INT,
	@begin	varchar(20) = null,
	@end varchar(20) = null
AS
BEGIN
	SET NOCOUNT ON;

	;WITH dt AS (
		SELECT 	
			CASE		
				WHEN b.AnswerID IS NOT NULL THEN AnswerName
				WHEN b.ClientQuestionText IS NOT NULL THEN b.ClientQuestionText
				ELSE NULL
			END AS AnswerName
		FROM 
			dbo.ClientReadList() INNER JOIN
			dbo.ClientTable a ON ClientID = RCL_ID INNER JOIN
			dbo.ClientQuestionTable b ON a.ClientID = b.ClientID INNER JOIN
			dbo.QuestionTable c ON c.QuestionID = b.QuestionID LEFT OUTER JOIN	
			dbo.AnswerTable e ON e.AnswerID = b.AnswerID
		WHERE c.QuestionID = @questionid 
			and (b.ClientQuestionDate >= @begin or @begin is null)
			and (b.ClientQuestionDate <= @end or @end is null)	
	 )


	SELECT
		AnswerName, COUNT(*) AS AnswerCount, 
		ROUND(CONVERT(DECIMAL(18, 10), COUNT(*) * 100)/(SELECT COUNT(*) FROM dt), 2) AS AnswerPercent
	FROM dt	
	GROUP BY AnswerName
	ORDER BY AnswerName
END