﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PERIOD_NEXT]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[PERIOD_NEXT] () RETURNS Int AS BEGIN RETURN NULL END')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

CREATE FUNCTION [dbo].[PERIOD_NEXT]
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
				SELECT DATEADD(MONTH, 1, PR_DATE)
				FROM dbo.PeriodTable
				WHERE PR_ID = @prid
			)


	-- Возвращение результата работы функции
	RETURN @result

END
GO
