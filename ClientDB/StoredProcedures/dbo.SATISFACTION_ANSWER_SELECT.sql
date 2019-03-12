USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SATISFACTION_ANSWER_SELECT]
	@SQ_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SA_ID, SA_TEXT, SA_ORDER, CONVERT(BIT, 0) AS SA_DEL
	FROM dbo.SatisfactionAnswer
	WHERE SA_ID_QUESTION = @SQ_ID
	ORDER BY SA_ORDER, SA_TEXT
END