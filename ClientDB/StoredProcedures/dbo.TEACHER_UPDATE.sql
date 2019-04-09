USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TEACHER_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(250),
	@LOGIN	VARCHAR(100),
	@REPORT	BIT,
	@NORMA	DECIMAL(4, 2)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.TeacherTable
	SET TeacherName = @NAME,
		TeacherLogin = @LOGIN,
		TeacherReport = @REPORT,
		TeacherNorma = @NORMA,
		TeacherLast = GETDATE()
	WHERE TeacherID = @ID
END