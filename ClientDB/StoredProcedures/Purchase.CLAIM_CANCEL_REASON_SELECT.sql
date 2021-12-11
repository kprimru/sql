USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLAIM_CANCEL_REASON_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLAIM_CANCEL_REASON_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[CLAIM_CANCEL_REASON_SELECT]
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

		SELECT CCR_ID, CCR_NAME, CCR_SHORT
		FROM Purchase.ClaimCancelReason
		WHERE @FILTER IS NULL
			OR CCR_NAME LIKE @FILTER
			OR CCR_SHORT LIKE @FILTER
		ORDER BY CCR_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLAIM_CANCEL_REASON_SELECT] TO rl_claim_cancel_reason_r;
GO
