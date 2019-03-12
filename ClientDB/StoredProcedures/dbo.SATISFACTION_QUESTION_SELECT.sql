USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SATISFACTION_QUESTION_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SQ_ID, SQ_TEXT, SQ_SINGLE, SQ_BOLD, SQ_ORDER,
		(
			SELECT COUNT(*) 
			FROM dbo.SatisfactionAnswer 
			WHERE SA_ID_QUESTION = SQ_ID
		) AS SQ_ANSWER
	FROM dbo.SatisfactionQuestion
	WHERE @FILTER IS NULL
		OR SQ_TEXT LIKE @FILTER
		OR SQ_ORDER LIKE @FILTER
	ORDER BY SQ_ORDER, SQ_TEXT
END