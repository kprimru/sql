USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[TEST_LOAD]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	SET @XML = CAST(@DATA AS XML)
	
	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	
	INSERT INTO Subhost.Test(NAME, QST_CNT, QST_SUCCESS, INSTANT_CHECK)	
		OUTPUT inserted.ID INTO @TBL
		SELECT c.value('(test_name)[1]', 'NVARCHAR(256)'), c.value('@quest_cnt', 'INT'), c.value('@success_value', 'INT'), 0
		FROM @XML.nodes('test') a(c)

	INSERT INTO Subhost.TestQuestion(ID_TEST, QST_TEXT, FULL_ANSWER, TP)		
		SELECT (SELECT ID FROM @TBL), c.value('(qst_name)[1]', 'NVARCHAR(512)'), ISNULL(c.value('(full_answer)[1]', 'NVARCHAR(MAX)'), ''), c.value('@tp', 'INT')
		FROM @XML.nodes('test/questions/qst') a(c)

	INSERT INTO Subhost.TestAnswer(ID_QUESTION, ANS_TEXT, CORRECT)		
		SELECT (SELECT ID FROM Subhost.TestQuestion WHERE ID_TEST = (SELECT ID FROM @TBL) AND QST_TEXT = c.value('(../../qst_name)[1]', 'NVARCHAR(512)')), c.value('(ans_name)[1]', 'NVARCHAR(512)'), c.value('@correct', 'INT')
		FROM @XML.nodes('test/questions/qst/answers/ans') a(c)
END
