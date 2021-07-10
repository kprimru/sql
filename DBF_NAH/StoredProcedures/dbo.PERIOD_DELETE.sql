USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Удалить регион с указанным
               кодом из справочника
*/

ALTER PROCEDURE [dbo].[PERIOD_DELETE]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.PeriodTable
	WHERE PR_ID = @periodid

	SET	NOCOUNT OFF
END




GO
GRANT EXECUTE ON [dbo].[PERIOD_DELETE] TO rl_period_d;
GO