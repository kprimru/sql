USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[TEACHER_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TeacherName, TeacherLogin, TeacherReport, TeacherNorma
	FROM dbo.TeacherTable
	WHERE TeacherID = @ID
END