USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MonthDateName]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[MonthDateName] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[MonthDateName]
(
	@Value	DateTime
)
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN
		(
			SELECT CASE DatePart(Month, @Value)
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
				ELSE 'Неизвестно'
			END
		);
END
GO
