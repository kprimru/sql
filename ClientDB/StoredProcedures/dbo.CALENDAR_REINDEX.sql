USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CALENDAR_REINDEX]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @INDEX	INT
	DECLARE	@MIN_DT	SMALLDATETIME
	DECLARE	@MAX_DT	SMALLDATETIME
	
	SELECT 
		@MIN_DT = MIN(CalendarDate), 
		@MAX_DT = MAX(CalendarDate), 
		@INDEX = 1
	FROM 
		dbo.Calendar
	
	WHILE @MIN_DT <= @MAX_DT
	BEGIN
		IF (
				SELECT CalendarWork 
				FROM dbo.Calendar 
				WHERE CalendarDate = @MIN_DT
			) = 1
			SET @INDEX = @INDEX + 1

		UPDATE dbo.Calendar
		SET CalendarIndex = @INDEX
		WHERE CalendarDate = @MIN_DT

		SET @MIN_DT = DATEADD(DAY, 1, @MIN_DT)
	END
END