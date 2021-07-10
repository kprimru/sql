USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Удалить систему из прейскуранта
*/

ALTER PROCEDURE [dbo].[PRICE_SYSTEM_DELETE]
	@pricesystemid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.PriceSystemTable
	WHERE PS_ID = @pricesystemid

	SET NOCOUNT OFF
END




GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_DELETE] TO rl_price_list_w;
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_DELETE] TO rl_price_val_w;
GO