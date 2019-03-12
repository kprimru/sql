USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[LESSON_PLACE_DELETE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.LessonPlaceTable
	WHERE LessonPlaceID = @ID
END