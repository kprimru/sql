USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Изменить данные о типе прейскуранта
               с указанным кодом
*/
ALTER PROCEDURE [dbo].[PRICE_TYPE_EDIT]
	@pricetypeid SMALLINT,
	@pricetypename VARCHAR(50),
	@group SMALLINT,
	@coef BIT = null,
	@order INT = NULL,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PriceTypeTable
	SET PT_NAME = @pricetypename,
		PT_ID_GROUP = @group,
		PT_COEF = @coef,
		PT_ORDER = @order,
		PT_ACTIVE = @active
	WHERE PT_ID = @pricetypeid

	UPDATE dbo.FieldTable
	SET FL_CAPTION = @pricetypename
	WHERE FL_NAME = 'PS_PRICE_' + CONVERT(VARCHAR, @pricetypeid)

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_EDIT] TO rl_price_type_w;
GO