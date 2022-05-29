USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_TECHNICAL_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_TECHNICAL_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_TECHNICAL_UPDATE]
	@Contract_Id			UniqueIdentifier,
	@Date					SmallDateTime,
	@ExpireDate				SmallDateTime,
	@Type_Id				Int,
	@PayType_Id				Int,
	@Discount_Id			Int,
	@ContractPrice			Money,
	@Comments				VarChar(Max),
	@DateFrom				SmallDateTime,
	@SignDate				SmallDateTime,
	@DateTo					SmallDateTime,
	@DocumentFlowType_Id	TinyInt,
	@ActSignPeriod_Id		SmallInt
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
		BEGIN TRAN;

		UPDATE [Contract].[Contract]
		SET [DateFrom]	= @DateFrom,
			[SignDate]	= @SignDate,
			[DateTo]	= @DateTo
		WHERE [Id] = @Contract_Id;

		UPDATE [Contract].[ClientContractsDetails]
		SET [ExpireDate]			= @ExpireDate,
			[Type_Id]				= @Type_Id,
			[PayType_Id]			= @PayType_Id,
			[Discount_Id]			= @Discount_Id,
			[ContractPrice]			= @ContractPrice,
			[Comments]				= @Comments,
			[DocumentFlowType_Id]	= @DocumentFlowType_Id,
			[ActSignPeriod_Id]		= @ActSignPeriod_Id
		WHERE [Contract_Id] = @Contract_Id
			AND [DATE] = @Date

		IF @@TranCount > 0
			COMMIT TRAN;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;

		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH;
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_TECHNICAL_UPDATE] TO rl_client_contract_tech;
GO
