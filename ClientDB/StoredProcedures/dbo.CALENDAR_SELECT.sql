USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CALENDAR_SELECT]
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@WEEK_DAY	INT = NULL,
	@HOLIDAY	BIT = 0	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CalendarID, CalendarDate, DayName, CalendarWork
	FROM 
		dbo.Calendar
		INNER JOIN dbo.DayTable ON DayID = CalendarWeekDayID
	WHERE (CalendarDate >= @BEGIN OR @BEGIN IS NULL)
		AND (CalendarDate <= @END OR @END IS NULL)
		AND (CalendarWeekDayID = @WEEK_DAY OR @WEEK_DAY IS NULL)
		AND (CalendarWork = 0 OR @HOLIDAY <> 1)
	ORDER BY CalendarDate
END