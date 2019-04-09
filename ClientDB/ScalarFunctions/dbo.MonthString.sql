USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MonthString]
(
	@DT	DATETIME
)
RETURNS VARCHAR(100)
WITH SCHEMABINDING
AS
BEGIN

	RETURN CASE DATEPART(MONTH, @DT)
			WHEN 1 THEN 'Январь'
			WHEN 2 THEN 'Февраль'
			WHEN 3 THEN 'Март'
			WHEN 4 THEN 'Апрель'
			WHEN 5 THEN 'Май'
			WHEN 6 THEN 'Июнь'
			WHEN 7 THEN 'Июль'
			WHEN 8 THEN 'Август'
			WHEN 9 THEN 'Сентябрь'
			WHEN 10 THEN 'Октябрь'
			WHEN 11 THEN 'Ноябрь'
			WHEN 12 THEN 'Декабрь'
			ELSE NULL
		END + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, @DT))
END
