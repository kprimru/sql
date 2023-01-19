USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_SETTING]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_SETTING] () RETURNS Int AS BEGIN RETURN NULL END')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

CREATE FUNCTION [dbo].[GET_SETTING]
(
	-- Список параметров функции
	@sname VARCHAR(500)
)
-- Тип, который возвращает
RETURNS VARCHAR(500)
AS
BEGIN
	-- переменная в которой будет храниться результат работы функции
	DECLARE @result VARCHAR(500)

	-- Тело функции
	SELECT @result = GS_VALUE
	FROM dbo.GlobalSettingsTable
	WHERE GS_NAME = @sname

	-- Возвращение результата работы функции
	RETURN @result

END

GO
