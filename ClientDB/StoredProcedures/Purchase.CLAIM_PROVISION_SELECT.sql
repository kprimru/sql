USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[CLAIM_PROVISION_SELECT]
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

		SELECT CP_ID, CP_NAME, CP_SHORT
		FROM Purchase.ClaimProvision
		WHERE @FILTER IS NULL
			OR CP_NAME LIKE @FILTER
			OR CP_SHORT LIKE @FILTER
		ORDER BY CP_SHORT, CP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLAIM_PROVISION_SELECT] TO rl_claim_provision_r;
GO
