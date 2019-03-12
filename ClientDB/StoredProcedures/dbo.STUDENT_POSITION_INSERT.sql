USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[STUDENT_POSITION_INSERT]
	@NAME	VARCHAR(150),
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.StudentPositionTable(StudentPositionName)
		VALUES(@NAME)
		
	SELECT @ID = SCOPE_IDENTITY()
END