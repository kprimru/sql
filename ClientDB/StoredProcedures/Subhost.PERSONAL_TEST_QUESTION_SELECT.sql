USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[PERSONAL_TEST_QUESTION_SELECT]
	@TEST	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, b.ID AS QST_ID, b.QST_TEXT, b.TP, a.STATUS, 
		CASE 
			b.TP WHEN 1 THEN a.ANS 
			ELSE 
				(
					SELECT '{' + CONVERT(NVARCHAR(64), ID_ANSWER) + '}' AS '@id'
					FROM Subhost.PersonalTestAnswer z
					WHERE z.ID_QUESTION = a.ID
					ORDER BY ID_ANSWER FOR XML PATH('item'), ROOT('root')
				) 
		END AS ANS,
		c.NOTE AS CHECK_NOTE, c.RESULT
	FROM 
		Subhost.PersonalTestQuestion a
		INNER JOIN Subhost.TestQuestion b ON a.ID_QUESTION = b.ID
		LEFT OUTER JOIN Subhost.CheckTestQuestion c ON c.ID_QUESTION = a.ID
	WHERE a.ID_TEST = @TEST
	ORDER BY ORD
END
