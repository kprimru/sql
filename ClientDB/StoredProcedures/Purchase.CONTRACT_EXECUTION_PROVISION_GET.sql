USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CONTRACT_EXECUTION_PROVISION_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CONTRACT_EXECUTION_PROVISION_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[CONTRACT_EXECUTION_PROVISION_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT CEP_NAME, CEP_SHORT
		FROM Purchase.ContractExecutionProvision
		WHERE CEP_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CONTRACT_EXECUTION_PROVISION_GET] TO rl_contract_execution_provision_r;
GO
