USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [dbo].[WorkDaysAdd]
(
	@DATE	SMALLDATETIME,	
	@DAYS	INT
)
RETURNS SMALLDATETIME
AS
BEGIN
	DECLARE @RESULT	SMALLDATETIME

	DECLARE @INDEX	INT

	SELECT TOP 1 @INDEX = CalendarIndex
	FROM 
		dbo.Calendar INNER JOIN
		dbo.DayTable ON DayID = CalendarWeekDayID
	WHERE CalendarDate >= @DATE
		AND DayOrder = 1
		AND CalendarWork = 1
	ORDER BY CalendarDate
	

	SELECT TOP 1 @RESULT = CalendarDate
	FROM dbo.Calendar
	WHERE CalendarIndex = @INDEX + (@DAYS - 1)
		AND CalendarWork = 1
	ORDER BY CalendarDate

	RETURN @RESULT
END