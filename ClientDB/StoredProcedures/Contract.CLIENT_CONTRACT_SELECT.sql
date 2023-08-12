USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT]
	@ClientId	Int
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

		SELECT
			C.[ID], C.[NUM_S], C.[SignDate], C.[DateFrom], C.[DateTo],
			D.[ExpireDate], D.[Type_Id], D.[PayType_Id], D.[Discount_Id], D.[ContractPrice], D.[Comments], D.[DocumentFlowType_Id], D.[ActSignPeriod_Id]
		FROM [Contract].[ClientContracts]	CC
		INNER JOIN [Contract].[Contract]	C	ON C.ID = CC.Contract_Id
		CROSS APPLY
		(
			SELECT TOP (1) CCD.[ExpireDate], CCD.[Type_Id], CCD.[PayType_Id], CCD.[Discount_Id], CCD.[ContractPrice], CCD.[Comments], CCD.[DocumentFlowType_Id], CCD.[ActSignPeriod_Id]
			FROM [Contract].[ClientContractsDetails] CCD
			WHERE CCD.[Contract_Id] = CC.[Contract_Id]
			ORDER BY CCD.[DATE] DESC
		) D
		WHERE CC.[Client_Id] = @ClientId
		ORDER BY C.[DateFrom] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_SELECT] TO rl_client_contract_r;
GO
