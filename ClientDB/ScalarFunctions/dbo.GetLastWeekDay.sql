USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GetLastWeekDay]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GetLastWeekDay] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION dbo.GetLastWeekDay -- находит последний указанный день недели (wday) в указанном месяце (@day)
(
	@wday	INT,
	@day	DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @res		DATETIME
	DECLARE @last_date	DATETIME

	IF DATEPART(m, @day) IN (1, 3, 5, 7, 8, 10, 12)
		SET @last_date = @day + (31 - DATEPART(D, @day))

	ELSE IF DATEPART(m, @day) IN (4, 6, 9, 11)
		SET @last_date = @day + (30 - DATEPART(D, @day))

	ELSE IF (DATEPART(m, @day) = 2) AND (DATEPART(y, @day)%4 = 0)  --ФЕВРАЛЬ В ВИСОКОСНЫЙ ГОД
		SET @last_date = @day + (29 - DATEPART(D, @day))

	ELSE IF (DATEPART(m, @day) = 2) AND (DATEPART(y, @day)%4 <> 0)  --ФЕВРАЛЬ В НЕ ВИСОКОСНЫЙ ГОД
		SET @last_date = @day + (28 - DATEPART(D, @day))

	IF DATEPART(dw, @last_date) = @wday
		SET @res = @last_date
	ELSE IF DATEPART(dw, @last_date) < @wday
		SET @res = @last_Date - (7 - (@wday - DATEPART(dw, @last_date)))
	ELSE IF DATEPART(dw, @last_date) > @wday
		SET @res = @last_date - (DATEPART(dw, @last_date) - @wday)

	RETURN @res
END
GO
