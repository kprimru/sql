USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Возвращает ID периода
               с указанным названием.
*/

ALTER PROCEDURE [dbo].[PERIOD_CHECK_NAME]
	@periodname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT PR_ID
	FROM dbo.PeriodTable
	WHERE PR_NAME = @periodname

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[PERIOD_CHECK_NAME] TO rl_period_w;
GO