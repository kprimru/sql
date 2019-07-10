USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Возвращает 0, если тип прейскуранта 
               можно удалить из справочника, 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[PRICE_TYPE_TRY_DELETE] 
	@pricetypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 29.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.PriceTable WHERE PP_ID_TYPE = @pricetypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить тип прейскуранта, так как имеются прейскуранты этого типа.'
		END

	-- связь PriceType <-> PriceSystem <-> System
	
	IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_TYPE = @pricetypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить тип прейскуранта, так как существует' +
							+ 'запись о стоимости систем по этому типу прейскуранта.' + CHAR(13)
		END
	
	--

	SELECT @res AS RES, @txt AS TXT
	  
	SET NOCOUNT OFF
END

