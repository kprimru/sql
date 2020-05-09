USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_GET]
	@Id			UniqueIdentifier,
	@Action		VarChar(100),
	@Date		SmallDateTime
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
			[NUM_S]				= C.[NUM_S],
			[ID_VENDOR]			= C.[ID_VENDOR],

			[DateFrom]			= C.[DateFrom],
			[SignDate]			= C.[SignDate],

			[DateTo]			= C.[DateTo],

			[DATE]				= D.[DATE],
			[ExpireDate]		= D.[ExpireDate],
			[Type_Id]			= D.[Type_Id],
			[PayType_Id]		= D.[PayType_Id],
			[Discount_Id]		= D.[Discount_Id],
			[ContractPrice]		= D.[ContractPrice],
			[Comments]			= D.[Comments],

			[DocumentType_Id]	= F.[Type_Id],
			[DocumentDate]		= F.[Date],
			[DocumentNote]		= F.[Note]
		FROM Contract.Contract C
		OUTER APPLY
		(
			SELECT TOP (1)
				D.[DATE], D.[ExpireDate], D.[Type_Id], D.[PayType_Id], D.[Discount_Id], D.[ContractPrice], D.[Comments]
			FROM Contract.ClientContractsDetails D
			WHERE	C.[Id] = D.[Contract_Id]
				AND (D.[DATE] = @Date OR @Date IS NULL)
			ORDER BY D.[DATE] DESC
		) D
		OUTER APPLY
		(
			SELECT TOP (1)
				F.[Type_Id], F.[Date], F.[Note]
			FROM Contract.ClientContractsDocuments F
			WHERE	F.[Contract_Id] = @Id
				AND F.[RowIndex] IS NULL
		) F
		WHERE ID = @Id

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