USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_SYSTEM_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_SYSTEM_EDIT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Изменить стоимость системы в
               прейскуранте
*/

ALTER PROCEDURE [dbo].[PRICE_SYSTEM_EDIT]
	@pricesystemid INT,
	@price MONEY
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

		UPDATE dbo.PriceSystemTable
		SET PS_PRICE = @price
		WHERE PS_ID = @pricesystemid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_EDIT] TO rl_price_list_w;
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_EDIT] TO rl_price_val_w;
GO
