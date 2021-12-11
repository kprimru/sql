USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[SIGN_PERIOD_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[SIGN_PERIOD_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[SIGN_PERIOD_SELECT]
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

		SELECT SP_ID, SP_NAME, SP_SHORT
		FROM Purchase.SignPeriod
		WHERE @FILTER IS NULL
			OR SP_NAME LIKE @FILTER
			OR SP_SHORT LIKE @FILTER
		ORDER BY SP_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[SIGN_PERIOD_SELECT] TO rl_sign_period_r;
GO
