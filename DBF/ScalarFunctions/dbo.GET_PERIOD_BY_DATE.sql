USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_PERIOD_BY_DATE]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_PERIOD_BY_DATE] () RETURNS Int AS BEGIN RETURN NULL END')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

CREATE FUNCTION [dbo].[GET_PERIOD_BY_DATE]
(
	-- Список параметров функции
	@date SMALLDATETIME
)
-- Тип, который возвращает
RETURNS INT
AS
BEGIN
	-- переменная в которой будет храниться результат работы функции
	DECLARE @result INT

	-- Тело функции
	SELECT @result = PR_ID
	FROM dbo.PeriodTable
	WHERE PR_DATE <= @date AND @date <= PR_END_DATE


	-- Возвращение результата работы функции
	RETURN @result

END
GO
