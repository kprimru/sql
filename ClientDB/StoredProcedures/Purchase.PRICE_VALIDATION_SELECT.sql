USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PRICE_VALIDATION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PRICE_VALIDATION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[PRICE_VALIDATION_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
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

		SELECT PV_ID, PV_NAME, PV_SHORT
		FROM Purchase.PriceValidation
		WHERE @FILTER IS NULL
			OR PV_NAME LIKE @FILTER
			OR PV_SHORT LIKE @FILTER
		ORDER BY PV_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PRICE_VALIDATION_SELECT] TO rl_price_validation_r;
GO
