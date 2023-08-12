USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SubjectNameView]', 'FN') IS NULL EXEC('CREATE FUNCTION [Seminar].[SubjectNameView] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [Seminar].[SubjectNameView]
(
    @SubjectName		VarChar(512),
	@ScheduleTypeName	VarChar(128)
)
RETURNS VarChar(512)
AS
BEGIN
    IF @SubjectName LIKE @ScheduleTypeName + '%'
		RETURN @SubjectName
	ELSE
		RETURN IsNull(@ScheduleTypeName + ': ', '') + @SubjectName;

	RETURN @SubjectName;
END
GO
