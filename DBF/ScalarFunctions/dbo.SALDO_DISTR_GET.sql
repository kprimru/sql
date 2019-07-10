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

CREATE FUNCTION [dbo].[SALDO_DISTR_GET]
(
	-- Список параметров функции
	@clientid INT,
	@distrid INT
)
-- Тип, который возвращает
RETURNS MONEY
AS
BEGIN
	-- переменная в которой будет храниться результат работы функции
	DECLARE @result MONEY

	-- Тело функции
	
	SELECT TOP 1 @result = SL_REST
	FROM dbo.SaldoTable
	WHERE SL_ID_DISTR = @distrid 
		AND SL_ID_CLIENT = @clientid
	ORDER BY SL_DATE DESC, SL_ID DESC

	-- Возвращение результата работы функции
	RETURN @result

END

