USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[APPLY_REASON_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[APPLY_REASON_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[APPLY_REASON_SELECT]
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

		SELECT AR_ID, AR_NAME, AR_SHORT
		FROM Purchase.ApplyReason
		WHERE @FILTER IS NULL
			OR AR_NAME LIKE @FILTER
			OR AR_SHORT LIKE @FILTER
		ORDER BY AR_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[APPLY_REASON_SELECT] TO rl_apply_reason_r;
GO
