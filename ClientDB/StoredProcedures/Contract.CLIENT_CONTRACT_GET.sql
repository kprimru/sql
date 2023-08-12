USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_GET]
	@Id			UniqueIdentifier,
	@Action		VarChar(100),
	@Date		SmallDateTime
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@ContractDeatilsExists	Bit,
		@SignDate				SmallDateTime,
		@DateFrom				SmallDateTime,
		@ExpireDate				SmalLDateTime,
		@PayType_Id				Int;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF EXISTS (
			SELECT TOP (1) *
			FROM [Contract].[ClientContractsDetails] D
			WHERE	D.[Contract_Id] = @Id
				AND (D.[DATE] = @Date OR @Date IS NULL)
			)
			SET @ContractDeatilsExists = 1
		ELSE
			SET @ContractDeatilsExists = 0;

		IF @ContractDeatilsExists = 0 BEGIN
			SELECT TOP (1)
				@ExpireDate	= C.[CO_END_DATE],
				@SignDate	= C.[CO_DATE],
				@DateFrom	= C.[CO_BEG_DATE],
				@PayType_Id = CCP.ContractPayID
			FROM [DBF].[dbo.ContractTable] AS C
			INNER JOIN [DBF].[dbo.ContractPayTable] AS CP ON CP.[COP_ID] = C.[CO_ID_PAY]
			INNER JOIN [dbo].[ContractPayTable] AS CCP ON CCP.[ContractPayDay] = CP.[COP_DAY] AND CCP.[ContractPayMonth] = CP.[COP_MONTH]
			WHERE C.[CO_NUM] = (SELECT CC.[NUM_S] FROM [Contract].[Contract] AS CC WHERE CC.[ID] = @Id)
			ORDER BY C.[CO_ID] DESC;
		END;

		SELECT
			[NUM_S]					= C.[NUM_S],
			[ID_VENDOR]				= C.[ID_VENDOR],

			[DateFrom]				= IsNull(C.[DateFrom], @DateFrom),
			[SignDate]				= IsNull(C.[SignDate], @SignDate),

			[DateTo]				= C.[DateTo],

			[DATE]					= D.[DATE],
			[ExpireDate]			= IsNull(D.[ExpireDate], @ExpireDate),
			[Type_Id]				= D.[Type_Id],
			[PayType_Id]			= IsNull(D.[PayType_Id], @PayType_Id),
			[Discount_Id]			= D.[Discount_Id],
			[ContractPrice]			= D.[ContractPrice],
			[Comments]				= D.[Comments],
			[DocumentFlowType_Id]	= D.[DocumentFlowType_Id],
			[ActSignPeriod_Id]		= D.[ActSignPeriod_Id],

			[DocumentType_Id]		= F.[Type_Id],
			[DocumentDate]			= F.[Date],
			[DocumentNote]			= F.[Note]
		FROM [Contract].[Contract] C
		OUTER APPLY
		(
			SELECT TOP (1)
				D.[DATE], D.[ExpireDate], D.[Type_Id], D.[PayType_Id], D.[Discount_Id], D.[ContractPrice], D.[Comments], D.[DocumentFlowType_Id], D.[ActSignPeriod_Id]
			FROM [Contract].[ClientContractsDetails] D
			WHERE	C.[Id] = D.[Contract_Id]
				AND (D.[DATE] = @Date OR @Date IS NULL)
			ORDER BY D.[DATE] DESC
		) D
		OUTER APPLY
		(
			SELECT TOP (1)
				F.[Type_Id], F.[Date], F.[Note]
			FROM [Contract].[ClientContractsDocuments] F
			WHERE	F.[Contract_Id] = @Id
				AND F.[RowIndex] IS NULL
		) F
		WHERE C.[ID] = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_GET] TO rl_client_contract_r;
GO
