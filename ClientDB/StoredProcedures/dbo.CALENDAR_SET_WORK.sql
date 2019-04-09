USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CALENDAR_SET_WORK]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DT	SMALLDATETIME
	DECLARE @WORK	BIT

	SELECT @DT = CalendarDate, @WORK = CalendarWork
	FROM dbo.Calendar
	WHERE CalendarID = @ID

	UPDATE dbo.Calendar
	SET CalendarWork = 
			CASE CalendarWork
				WHEN 1 THEN 0
				WHEN 0 THEN 1
				ELSE NULL
			END
	WHERE CalendarID = @ID

	UPDATE dbo.Calendar
	SET CalendarIndex = CalendarIndex +
			CASE @WORK
				WHEN 1 THEN -1
				WHEN 0 THEN 1
				ELSE 0
			END
	WHERE CalendarDate >= @DT
END