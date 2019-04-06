USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_CLIENT_STUDY]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		StudyDate, 
		StudyDate AS StudyDateStr,
		RepeatDate AS RepeatDateStr,
		LessonPlaceName, a.LessonPlaceID, TeacherName, a.TeacherID, OwnershipName, a.OwnershipID,
		SystemNeed, Recomend, StudyNote, ClientStudyID, Teached
	FROM 
		dbo.ClientStudyTable a LEFT OUTER JOIN
		dbo.LessonPlaceTable b ON a.LessonPlaceId = b.LessonPlaceID LEFT OUTER JOIN
		dbo.TeacherTable c ON a.TeacherID = c.TeacherID LEFT OUTER JOIN
		dbo.OwnershipTable d ON a.OwnershipID = d.OwnershipID
	WHERE ClientID = @clientid
	ORDER BY StudyDate DESC, ClientStudyID
END
