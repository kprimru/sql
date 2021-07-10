USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 19.11.2008
Описание:	  Возвращает 0, если подхост можно
                удалить из справочника (ни в
               одной таблице он не указан),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_TRY_DELETE]
	@subhostcityid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''


	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_TRY_DELETE] TO rl_subhost_city_d;
GO