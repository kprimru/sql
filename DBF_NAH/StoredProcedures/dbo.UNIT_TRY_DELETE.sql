USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если тип системы
               можно удалить,
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[UNIT_TRY_DELETE]
	@unitid SMALLINT
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 28.04.2009, В.Богдан

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF

END











GO
GRANT EXECUTE ON [dbo].[UNIT_TRY_DELETE] TO rl_unit_d;
GO