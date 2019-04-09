USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_QUESTION_FILTER]
	@questionid INT,
	@serviceid INT,
	@begin smalldatetime = null,
	@end   smalldatetime = null
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientFullName, ClientQuestionDate, ClientQuestionComment,
		CASE		
			WHEN b.AnswerID IS NOT NULL THEN AnswerName
			WHEN b.ClientQuestionText IS NOT NULL THEN b.ClientQuestionText
			ELSE NULL
		END AS AnswerName, ServiceName
	FROM 
		dbo.ClientReadList() INNER JOIN
		dbo.ClientTable a ON RCL_ID = ClientID INNER JOIN
		dbo.ClientQuestionTable b ON a.ClientID = b.ClientID INNER JOIN
		dbo.QuestionTable c ON c.QuestionID = b.QuestionID INNER JOIN	
		dbo.ServiceTable d ON d.ServiceID = a.ClientServiceID LEFT OUTER JOIN
		dbo.AnswerTable e ON e.AnswerID = b.AnswerID
	WHERE (ServiceID = @serviceid OR @serviceid IS NULL)
		AND (c.QuestionID = @questionid OR @questionid IS NULL)	
		AND (b.CLientQuestionDate >= @begin or @begin IS NULL)
		AND (b.CLientQuestionDate <= @end or @end IS NULL)
	ORDER BY ClientFullName, QuestionName
END