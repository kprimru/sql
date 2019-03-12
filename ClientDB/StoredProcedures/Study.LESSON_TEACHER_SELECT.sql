USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Study].[LESSON_TEACHER_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT TEACHER
	FROM Study.Lesson
	WHERE STATUS = 1
	ORDER BY TEACHER
END
