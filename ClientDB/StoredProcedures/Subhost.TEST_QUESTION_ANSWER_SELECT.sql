USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[TEST_QUESTION_ANSWER_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, ANS_TEXT, CORRECT
	FROM Subhost.TestAnswer
	WHERE ID_QUESTION = @ID
	ORDER BY NEWID()
END
