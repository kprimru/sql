USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_STUDY_PRICE_EDIT]
	@PR_ID	SMALLINT,
	@LS_ID	SMALLINT,
	@PRICE	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT *
			FROM Subhost.SubhostLessonPrice
			WHERE SLP_ID_PERIOD = @PR_ID
				AND SLP_ID_LESSON = @LS_ID
		)
	BEGIN
		UPDATE Subhost.SubhostLessonPrice
		SET SLP_PRICE = @PRICE
		WHERE SLP_ID_PERIOD = @PR_ID
			AND SLP_ID_LESSON = @LS_ID
	END
	ELSE
	BEGIN
		INSERT INTO Subhost.SubhostLessonPrice(SLP_ID_PERIOD, SLP_ID_LESSON, SLP_PRICE)
			SELECT @PR_ID, @LS_ID, @PRICE
	END
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_STUDY_PRICE_EDIT] TO rl_subhost_calc;
GO