USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[PRICE_SHOW]
	@pricetypeid INT,
	@periodid INT
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

		SELECT PS_ID, SYS_SHORT_NAME, SYS_ID, PS_PRICE, SYS_ORDER
		FROM
			dbo.PriceSystemTable a INNER JOIN
			dbo.SystemTable d ON d.SYS_ID = a.PS_ID_SYSTEM
		WHERE PS_ID_TYPE = @pricetypeid AND PS_ID_PERIOD = @periodid

		UNION ALL

		SELECT PS_ID, PGD_NAME, PGD_ID, PS_PRICE, 9999999
		FROM
			dbo.PriceSystemTable a INNER JOIN
			dbo.PriceGoodTable d ON d.PGD_ID = a.PS_ID_PGD
		WHERE PS_ID_TYPE = @pricetypeid AND PS_ID_PERIOD = @periodid

		ORDER BY SYS_ORDER, SYS_SHORT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_SHOW] TO rl_price_list_r;
GRANT EXECUTE ON [dbo].[PRICE_SHOW] TO rl_price_r;
GRANT EXECUTE ON [dbo].[PRICE_SHOW] TO rl_price_val_r;
GO
