USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_SELECT_LOOKUP]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_LOOKUP]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_LOOKUP]
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
			C.[ID],
			NUM_S = C.[NUM_S] + ISNULL(' от ' + CONVERT(VARCHAR(20), C.[SignDate], 104), ''),
			[DateFrom], [DateTo], [ExpireDate], [ContractTypeName], [ContractPayName], [DiscountValue], [ContractPrice], [Comments],
			[DocumentFlowTypeName] = F.[Name], [ActSignPeriodName] = S.[Name]
		FROM [Contract].[ClientContracts]	CC
		INNER JOIN [Contract].[Contract]	C	ON C.ID = CC.Contract_Id
		CROSS APPLY
		(
			SELECT TOP (1) [ExpireDate], [Type_Id], [PayType_Id], [Discount_Id], [ContractPrice], [Comments], [DocumentFlowType_Id], [ActSignPeriod_Id]
			FROM [Contract].[ClientContractsDetails] CCD
			WHERE CCD.[Contract_Id] = CC.[Contract_Id]
			ORDER BY CCD.[DATE] DESC
		) D
		INNER JOIN [dbo].[DiscountTable] DD ON DD.[DiscountID] = D.[Discount_Id]
		INNER JOIN [dbo].[ContractPayTable] P ON P.[ContractPayID] = D.[PayType_Id]
		INNER JOIN [dbo].[ContractTypeTable] T ON T.[ContractTypeID] = D.Type_Id
		LEFT JOIN [Contract].[Contracts->Documents Flow Types] AS F ON F.[Id] = D.[DocumentFlowType_Id]
		LEFT JOIN [Contract].[Contracts->Act Sign Periods] AS S ON S.[Id] = D.[ActSignPeriod_Id]
		WHERE CC.[Client_Id] = @ClientId
		ORDER BY [DateFrom] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_SELECT_LOOKUP] TO rl_client_contract_r;
GO
