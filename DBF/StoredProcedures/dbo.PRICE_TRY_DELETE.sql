USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Возвращает 0, если прейскурант
               можно удалить из справочника, 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[PRICE_TRY_DELETE] 
	@priceid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 29.04.2009, В.Богдан
	-- убрано 15.06.2009, А.Денисов. Причина: схемы вообще в печь 
	/*
	IF EXISTS(SELECT * FROM SchemaTable WHERE SCH_ID_PRICE = @priceid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить прейскурант, так как имеются схемы с этим прейскурантом.'
		END
	--
	*/

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF

END

