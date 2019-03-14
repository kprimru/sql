USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[SUBHOST_STUDY_PRICE_SELECT]
	@PR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;		

	SELECT 
		LS_ID, LS_NAME, 
		(
			SELECT SLP_PRICE
			FROM Subhost.SubhostLessonPrice 
			WHERE SLP_ID_LESSON = LS_ID AND SLP_ID_PERIOD = @PR_ID
		) AS SLP_PRICE
	FROM 
		Subhost.Lesson
	WHERE LS_ACTIVE = 1
	ORDER BY LS_ORDER	
END
