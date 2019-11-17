USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Poll].[BLANK_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@NAME		NVARCHAR(128),
	@QUESTION	NVARCHAR(MAX),
	@ANSWER		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		SET @ID = NEWID()
		
		INSERT INTO Poll.Blank(ID, NAME) VALUES(@ID, @NAME)
		
		
	END
	ELSE
	BEGIN
		UPDATE Poll.Blank
		SET NAME = @NAME
		WHERE ID = @ID
		
		DELETE FROM Poll.Answer WHERE ID_QUESTION IN (SELECT ID FROM Poll.Question WHERE ID_BLANK = @ID)
		DELETE FROM Poll.Question WHERE ID_BLANK = @ID
	END
	
	DECLARE @XML XML
	
	SET @XML = CAST(@QUESTION AS XML)
	
	INSERT INTO Poll.Question(ID, ID_BLANK, TP, ANS_MIN, ANS_MAX, NAME, ORD)		
		SELECT 
			ID, @ID, TP, ANS_MIN, ANS_MAX, NAME, ROW_NUMBER() OVER(ORDER BY ORD)
		FROM
			(
				SELECT 
					c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
					c.value('(@tp)', 'TINYINT') AS TP,
					c.value('(@ans_min)', 'SMALLINT') AS ANS_MIN,
					c.value('(@ans_max)', 'SMALLINT') AS ANS_MAX,
					c.value('(@name)', 'NVARCHAR(512)') AS NAME,
					c.value('(@ord)', 'INT') AS ORD
				FROM @XML.nodes('/root/question') a(c)
			) AS o_O
		
	SET @XML = CAST(@ANSWER AS XML)
		
	INSERT INTO Poll.Answer(ID, ID_QUESTION, NAME, ORD)
		SELECT ID, QUEST, NAME, ROW_NUMBER() OVER(PARTITION BY QUEST ORDER BY ORD)
		FROM 
			(
				SELECT 
					c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
					c.value('(@id_question)', 'UNIQUEIDENTIFIER') AS QUEST,
					c.value('(@name)', 'NVARCHAR(512)') AS NAME,
					c.value('(@ord)', 'INT') AS ORD
				FROM @XML.nodes('/root/answer') a(c)
			) AS o_O
END
