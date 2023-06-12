USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_SELECT_DETAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_DETAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_DETAIL]
	@Contract_Id	UniqueIdentifier
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

		SELECT [DATE], [ExpireDate], [Type_Id], [PayType_Id], [Discount_Id], [ContractPrice], [Comments], [DocumentFlowType_Id], [ActSignPeriod_Id]
		FROM [Contract].[ClientContractsDetails]
		WHERE [Contract_Id] = @Contract_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_SELECT_DETAIL] TO rl_client_contract_r;
GO
