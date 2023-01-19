USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_ADD]  AS SELECT 1')
GO
/*
Автор:		  Денисов Алексей
Описание:
*/
ALTER PROCEDURE [dbo].[PRICE_ADD]
	@pricename VARCHAR(50),
	@pricetypeid INT,
	@pricecoefmul NUMERIC(8, 4),
	@pricecoefadd MONEY,
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

		INSERT INTO dbo.PriceTable(PP_NAME, PP_ID_TYPE, PP_COEF_MUL, PP_COEF_ADD, PP_ACTIVE)
		VALUES (@pricename, @pricetypeid, @pricecoefmul, @pricecoefadd, @active)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_ADD] TO rl_price_w;
GO
