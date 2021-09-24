USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Добавить тип прейскуранта в
               справочник
*/

ALTER PROCEDURE [dbo].[PRICE_TYPE_ADD]
	@pricetypename VARCHAR(20),
	@group SMALLINT,
	@coef BIT = null,
	@order INT = null,
	@active BIT = 1,
	@returnvalue BIT = 1
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

		INSERT INTO dbo.PriceTypeTable(PT_NAME, PT_ID_GROUP, PT_COEF, PT_ORDER, PT_ACTIVE)
		VALUES (@pricetypename, @group, @coef, @order, @active)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		INSERT INTO dbo.FieldTable(FL_NAME, FL_WIDTH, FL_CAPTION)
			SELECT 'PS_PRICE_' + CONVERT(VARCHAR, SCOPE_IDENTITY()), 80, @pricetypename

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_ADD] TO rl_price_type_w;
GO
