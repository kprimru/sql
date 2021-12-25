USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_SELECT_FROM_PRICECOUNT]
	@IsDepo	Bit
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		EXEC [PC275-SQL\GAMMA].[BuhDB].[dbo].[PRICE_EXPORT_SELECT] @IsDepo;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_SELECT_FROM_PRICECOUNT] TO rl_price_list_w;
GRANT EXECUTE ON [dbo].[PRICE_SELECT_FROM_PRICECOUNT] TO rl_price_w;
GO
