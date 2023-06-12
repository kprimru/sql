USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MonthNameRus]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[MonthNameRus] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[DateNameRus]
(
	@Date Date
)
RETURNS VARCHAR(255)
AS
BEGIN
	RETURN CASE DatePart(Month, @Date)
		WHEN 1 THEN 'январь'
		WHEN 2 THEN 'февраль'
		WHEN 3 THEN 'март'
		WHEN 4 THEN 'апрель'
		WHEN 5 THEN 'май'
		WHEN 6 THEN 'июнь'
		WHEN 7 THEN 'июль'
		WHEN 8 THEN 'август'
		WHEN 9 THEN 'сентябрь'
		WHEN 10 THEN 'октябрь'
		WHEN 11 THEN 'ноябрь'
		WHEN 12 THEN 'декабрь'
		ELSE 'Неизвестно'
	END
END
GO
