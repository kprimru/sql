USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PAY_PERIOD_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PAY_PERIOD_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PAY_PERIOD_SELECT]
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

		SELECT PP_ID, PP_NAME, PP_SHORT
		FROM Purchase.PayPeriod
		WHERE @FILTER IS NULL
			OR PP_NAME LIKE @FILTER
			OR PP_SHORT LIKE @FILTER
		ORDER BY PP_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PAY_PERIOD_SELECT] TO rl_pay_period_r;
GO
