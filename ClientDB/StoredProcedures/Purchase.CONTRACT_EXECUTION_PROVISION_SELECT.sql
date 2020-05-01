USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[CONTRACT_EXECUTION_PROVISION_SELECT]
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

		SELECT CEP_ID, CEP_NAME, CEP_SHORT
		FROM Purchase.ContractExecutionProvision
		WHERE @FILTER IS NULL
			OR CEP_NAME LIKE @FILTER
			OR CEP_SHORT LIKE @FILTER
		ORDER BY CEP_SHORT, CEP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Purchase].[CONTRACT_EXECUTION_PROVISION_SELECT] TO rl_contract_execution_provision_r;
GO