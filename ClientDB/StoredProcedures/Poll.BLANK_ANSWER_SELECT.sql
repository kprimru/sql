USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Poll].[BLANK_ANSWER_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		b.ID, a.ID AS ID_QUESTION, b.NAME, b.ORD		
	FROM 
		Poll.Question a
		INNER JOIN Poll.Answer b ON a.ID = b.ID_QUESTION
	WHERE ID_BLANK = @ID
	ORDER BY b.ORD
END
