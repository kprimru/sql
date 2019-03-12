USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[LESSON_PLACE_INSERT]	
	@NAME	VARCHAR(100),
	@REPORT	BIT,
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.LessonPlaceTable(LessonPlaceName, LessonPlaceReport)
		VALUES(@NAME, @REPORT)
		
	SELECT @ID = SCOPE_IDENTITY()
END