USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Удалить тип прейскуранта с
               указанным кодом из справочника
*/

ALTER PROCEDURE [dbo].[PRICE_GOOD_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.PriceGoodTable
	WHERE PGD_ID = @id

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[PRICE_GOOD_DELETE] TO rl_price_good_d;
GO