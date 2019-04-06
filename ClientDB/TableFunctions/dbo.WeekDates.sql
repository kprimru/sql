USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WeekDates]
(
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
)
RETURNS @WEEK TABLE
		(
			WEEK_ID	INT IDENTITY(1, 1),
			WBEGIN SMALLDATETIME, 
			WEND SMALLDATETIME
		)
AS
BEGIN
	DECLARE @TBEGIN SMALLDATETIME
	DECLARE @TEND SMALLDATETIME

	IF @BEGIN > @END
		RETURN
	ELSE
	BEGIN
		SET @TBEGIN = @BEGIN
		SET @TEND = DATEADD(DAY, 7 - DATEPART(WEEKDAY, @BEGIN), @BEGIN)
		
		IF @TEND >= @END
			SET @TEND = @END

		INSERT INTO @WEEK(WBEGIN, WEND) VALUES (@TBEGIN, @TEND)

		SET @TBEGIN = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @TBEGIN), @TBEGIN)

		WHILE @TEND < @END
		BEGIN
			SET @TBEGIN = DATEADD(WEEK, 1, @TBEGIN)
			SET @TEND = DATEADD(WEEK, 1, @TEND)

			IF @TEND >= @END
				SET @TEND = @END

			INSERT INTO @WEEK(WBEGIN, WEND) VALUES (@TBEGIN, @TEND)
		END
	END
	
	RETURN 
END
