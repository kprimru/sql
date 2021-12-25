USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GetLastWedFri]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GetLastWedFri] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION dbo.GetLastWedFri
(
	@day	DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @last_date	DATETIME

	IF DATEPART(m, @day) IN (1, 3, 5, 7, 8, 10, 12)
		SET @last_date = @day + (31 - DATEPART(D, @day))

	ELSE IF DATEPART(m, @day) IN (4, 6, 9, 11)
		SET @last_date = @day + (30 - DATEPART(D, @day))

	ELSE IF (DATEPART(m, @day) = 2) AND (DATEPART(y, @day)%4 = 0)  --ФЕВРАЛЬ В ВИСОКОСНЫЙ ГОД
		SET @last_date = @day + (29 - DATEPART(D, @day))

	ELSE IF (DATEPART(m, @day) = 2) AND (DATEPART(y, @day)%4 <> 0)  --ФЕВРАЛЬ В НЕ ВИСОКОСНЫЙ ГОД
		SET @last_date = @day + (28 - DATEPART(D, @day))




	IF DATEPART(dw, @last_date) = 1
		SET @last_date = @last_date - 3

	ELSE IF DATEPART(dw, @last_date) = 2
		SET @last_date = @last_date - 4

	ELSE IF DATEPART(dw, @last_date) = 4
		SET @last_date = @last_date - 1

	ELSE IF DATEPART(dw, @last_date) = 6
		SET @last_date = @last_date - 1

	ELSE IF DATEPART(dw, @last_date) = 7
			SET @last_date = @last_date - 2




	WHILE(@last_date - @day <= 1)
	BEGIN
		IF (DATEPART(dw, @last_date) = 3)
			SET @last_date = @last_date + 2

		ELSE IF (@last_date - @day <= 1) AND (DATEPART(dw, @last_date) = 5)
			SET @last_date = @last_date + 5
	END


	RETURN @last_date
END
GO
