USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ================================================
-- Автор:			Денисов Алексей
-- Дата создания:	25.08.2008
-- Дата изменения:	10.02.2009
-- Описание:		Возвращает список дистрибутивов
--					ТО, которые нужно включать
--					в отчет
-- ================================================

ALTER FUNCTION [dbo].[GET_CLIENT_DISTR]
(
	@toid int,
	@prid smallint
)
RETURNS varchar(250)
AS
BEGIN
	DECLARE @resstr varchar(250)

	SET @resstr = ''

	SELECT @resstr = @resstr + HST_REG_NAME +
					(CASE DIS_COMP_NUM
							WHEN 1 THEN CONVERT(varchar, DIS_NUM)
							ELSE CONVERT(varchar, DIS_NUM) + '/' + CONVERT(varchar, DIS_COMP_NUM)
					END
					) + ','
	FROM	dbo.TODistrView		a		INNER JOIN
			dbo.PeriodRegExceptView	b	ON	a.DIS_NUM =	b.REG_DISTR_NUM AND
									a.DIS_COMP_NUM = b.REG_COMP_NUM AND
									a.SYS_ID = b.REG_ID_SYSTEM
	WHERE TD_ID_TO = @toid AND SYS_REPORT = 1  AND REG_ID_PERIOD = @prid
	ORDER BY HST_REG_NAME, DIS_NUM, DIS_COMP_NUM

	IF LEN(@resstr) > 1
		SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

	RETURN @resstr

END



GO
