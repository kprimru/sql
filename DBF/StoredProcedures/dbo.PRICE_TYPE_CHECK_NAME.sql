USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_TYPE_CHECK_NAME]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_TYPE_CHECK_NAME]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Возвращает ID типа прейскуранта
               с указанным названием.
*/

ALTER PROCEDURE [dbo].[PRICE_TYPE_CHECK_NAME]
	@pricetypename VARCHAR(100)
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

		SELECT PT_ID
		FROM dbo.PriceTypeTable
		WHERE PT_NAME = @pricetypename

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_CHECK_NAME] TO rl_price_type_w;
GO
