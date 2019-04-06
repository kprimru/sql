USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_STUDY_PRICE_COPY]
	@SOURCE	SMALLINT,
	@DEST	SMALLINT,
	@COEF	DECIMAL(8, 4),
	@REPL	BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF @REPL = 1
		DELETE FROM Subhost.SubhostLessonPrice WHERE SLP_ID_PERIOD = @DEST
	
	INSERT INTO Subhost.SubhostLessonPrice(SLP_ID_PERIOD, SLP_ID_LESSON, SLP_PRICE)
		SELECT @DEST, SLP_ID_LESSON, CONVERT(MONEY, SLP_PRICE * @COEF)
		FROM Subhost.SubhostLessonPrice
		WHERE SLP_ID_PERIOD = @SOURCE
END
