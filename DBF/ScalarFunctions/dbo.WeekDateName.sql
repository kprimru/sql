USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[WeekDateName]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[WeekDateName] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[WeekDateName]
(
	@Value	DateTime
)
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN
		(
			SELECT CASE DatePart(WeekDay, @Value)
				WHEN 1 THEN 'Понедельник'
				WHEN 2 THEN 'Вторник'
				WHEN 3 THEN 'Среда'
				WHEN 4 THEN 'Четверг'
				WHEN 5 THEN 'Пятница'
				WHEN 6 THEN 'Суббота'
				WHEN 7 THEN 'Воскресенье'
				ELSE 'Неизвестно'
			END
		);
END
GO
