USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[SUBHOST_LESSON_COUNT_SELECT]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LS_ID, LS_NAME, SS_COUNT
	FROM 
		Subhost.SubhostStudy a INNER JOIN
		Subhost.Lesson ON LS_ID = SS_ID_LESSON 
	WHERE SS_ID_PERIOD = @PR_ID AND SS_ID_SUBHOST = @SH_ID
END
