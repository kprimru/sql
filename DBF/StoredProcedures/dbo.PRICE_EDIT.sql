USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Изменить данные о прейскуранте
                с указанным кодом
*/

ALTER PROCEDURE [dbo].[PRICE_EDIT]
	@priceid SMALLINT,
	@pricename VARCHAR(50),
	@pricetypeid SMALLINT,
	@pricecoefmul NUMERIC(8, 4),
	@pricecoefadd MONEY,
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

		UPDATE dbo.PriceTable
		SET PP_NAME = @pricename,
			PP_ID_TYPE = @pricetypeid,
			PP_COEF_MUL = @pricecoefmul,
			PP_COEF_ADD = @pricecoefadd,
			PP_ACTIVE = @active
		WHERE PP_ID = @priceid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_EDIT] TO rl_price_w;
GO