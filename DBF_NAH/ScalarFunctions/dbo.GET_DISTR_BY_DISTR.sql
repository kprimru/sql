USE [DBF_NAH]
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

ALTER FUNCTION [dbo].[GET_DISTR_BY_DISTR]
(
	-- Список параметров функции
	@distrnum INT,
	@sys VARCHAR(10)
)
-- Тип, который возвращает
RETURNS INT
AS
BEGIN
	-- переменная в которой будет храниться результат работы функции
	DECLARE @result INT

	SET @result = NULL

	-- Тело функции

	SELECT @result = DIS_ID
	FROM dbo.DistrTable INNER JOIN
		dbo.SystemTable ON DIS_ID_SYSTEM = SYS_ID
	WHERE SYS_ID_HOST IN
			(
				SELECT HST_ID
				FROM dbo.HostTable g INNER JOIN
					dbo.SystemTable h ON g.HST_ID = h.SYS_ID_HOST
				WHERE h.SYS_PSEDO = @sys
			) AND DIS_NUM = @distrnum
		AND DIS_COMP_NUM =
			(
				SELECT MAX(DIS_COMP_NUM)
				FROM dbo.DistrTable INNER JOIN
					dbo.SystemTable ON DIS_ID_SYSTEM = SYS_ID
				WHERE SYS_ID_HOST IN
			(
				SELECT HST_ID
				FROM dbo.HostTable g INNER JOIN
					dbo.SystemTable h ON g.HST_ID = h.SYS_ID_HOST
				WHERE h.SYS_PSEDO = @sys
			) AND DIS_NUM = @distrnum
			)


	RETURN @result

END




GO
