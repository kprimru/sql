USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

ALTER FUNCTION [dbo].[PERIOD_PREV]
(
	-- Список параметров функции
	@prid SMALLINT
)
-- Тип, который возвращает
RETURNS SMALLINT
AS
BEGIN
	-- переменная в которой будет храниться результат работы функции
	DECLARE @result SMALLINT

	-- Тело функции
	SELECT @result = PR_ID 
	FROM dbo.PeriodTable
	WHERE PR_DATE = 
			(
				SELECT DATEADD(MONTH, -1, PR_DATE)
				FROM dbo.PeriodTable 
				WHERE PR_ID = @prid
			)


	-- Возвращение результата работы функции
	RETURN @result

END
