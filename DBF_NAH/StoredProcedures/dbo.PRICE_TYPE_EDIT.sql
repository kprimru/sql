USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_TYPE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_TYPE_EDIT]  AS SELECT 1')
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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_EDIT] TO rl_price_type_w;
GO
