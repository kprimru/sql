USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SubjectNoteView]', 'FN') IS NULL EXEC('CREATE FUNCTION [Seminar].[SubjectNoteView] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [Seminar].[SubjectNoteView]
(
    @Note				VarChar(Max),
	@ScheduleDate		SmallDateTime,
	@ScheduleTime		SmallDateTime,
	@PlaceTemplate		VarChar(Max)
)
RETURNS VarChar(512)
AS
BEGIN

	DECLARE
		@DateStr	VarChar(100),
		@TimeStr	VarChar(100);

	SELECT @DateStr =
		Convert(VarCHar(20), DatePart(Day, @ScheduleDate)) + ' ' + M.[ROD] + ' ' + Convert(VarChar(20), DatePart(Year, @ScheduleDate)) + ' г. (' + D.[DayName] + ')'
	FROM [dbo].[Month] AS M
	CROSS JOIN [dbo].[DayTable] AS D
	WHERE M.[NUM] = DatePart(Month, @ScheduleDate)
		AND D.[DayOrder] = DatePart(WeekDay, @ScheduleDate);

	SET @Note = Replace(@Note, '%PlaceTemplate%', @PlaceTemplate);
	SET @Note = Replace(@Note, '%Date%', @DateStr);
	SET @Note = Replace(@Note, '%Time%', Left(Convert(VarChar(20), @ScheduleTime, 108), 5));

	RETURN @Note;
END
GO
