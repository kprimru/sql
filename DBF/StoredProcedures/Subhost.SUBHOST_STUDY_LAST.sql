USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_STUDY_LAST]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM Subhost.SubhostStudy
	WHERE SS_ID_SUBHOST = @SH_ID AND SS_ID_PERIOD = @PR_ID

	INSERT INTO Subhost.SubhostLessonPrice(SLP_ID_PERIOD, SLP_ID_LESSON, SLP_PRICE)
		SELECT @PR_ID, SLP_ID_LESSON, SLP_PRICE
		FROM Subhost.SubhostLessonPrice a
		WHERE SLP_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)
			AND NOT EXISTS
				(
					SELECT *
					FROM Subhost.SubhostLessonPrice b
					WHERE b.SLP_ID_PERIOD = @PR_ID
						AND b.SLP_ID_LESSON = a.SLP_ID_LESSON
				)

	INSERT INTO Subhost.SubhostStudy(
			SS_ID_SUBHOST, SS_ID_PERIOD, SS_ID_LESSON, SS_COUNT)
		SELECT 
			SS_ID_SUBHOST, @PR_ID, SS_ID_LESSON, SS_COUNT			
		FROM Subhost.SubhostStudy
		WHERE SS_ID_SUBHOST = @SH_ID AND SS_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)
END
