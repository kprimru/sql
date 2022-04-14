USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_CONDITIONS_CHANGE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_CONDITIONS_CHANGE]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_CONDITIONS_CHANGE]
	@Contract_Id			UniqueIdentifier,
	@Date					SmallDateTime,
	@ExpireDate				SmallDateTime,
	@Type_Id				Int,
	@PayType_Id				Int,
	@Discount_Id			Int,
	@ContractPrice			Money,
	@Comments				VarChar(Max),
	@DocumentExists			Bit,
	@DocumentType_Id		UniqueIdentifier,
	@DocumentDate			SmallDateTime,
	@DocumentNote			VarChar(Max),
	@DocumentFlowType_Id	TinyInt
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

	DECLARE
		@ConditionChanged			Bit,
		@OldExpireDate				SmallDateTime,
		@OldType_Id					Int,
		@OldPayType_Id				Int,
		@OldDiscount_Id				Int,
		@OldContractPrice			Money,
		@OldComments				VarChar(Max),
		@OldDocumentFlowType_Id		TinyInt;

	BEGIN TRY
		BEGIN TRAN;

		IF NOT EXISTS(SELECT * FROM [Contract].[Contract] WHERE [ID] = @Contract_Id AND [DateTo] IS NULL)
			RaisError('Ошибка! Договор закрыт!', 16, 1);

		IF EXISTS(SELECT * FROM [Contract].[ClientContractsDetails] WHERE [Contract_Id] = @Contract_Id AND [DATE] >= @Date)
			RaisError('Ошибка! Невозможно менять условия договора в прошлом!', 16, 1)

		SELECT TOP (1)
			@OldExpireDate			= [ExpireDate],
			@OldType_Id				= [Type_Id],
			@OldPayType_Id			= [PayType_Id],
			@OldDiscount_Id			= [Discount_Id],
			@OldContractPrice		= [ContractPrice],
			@OldComments			= [Comments],
			@OldDocumentFlowType_Id	= [DocumentFlowType_Id]
		FROM [Contract].[ClientContractsDetails]
		WHERE [Contract_Id] = @Contract_Id
		ORDER BY [DATE] DESC;

		IF
				[Common].[Is Equal(SmallDateTime)](@ExpireDate, @OldExpireDate) = 0
			OR	[Common].[Is Equal(Int)](@Type_Id, @OldType_Id) = 0
			OR	[Common].[Is Equal(Int)](@PayType_Id, @OldPayType_Id) = 0
			OR	[Common].[Is Equal(Int)](@Discount_Id, @OldDiscount_Id) = 0
			OR	[Common].[Is Equal(Money)](@ContractPrice, @OldContractPrice) = 0
			OR	[Common].[Is Equal(VarChar)](@Comments, @OldComments) = 0
			OR	[Common].[Is Equal(TinyInt)](@DocumentFlowType_Id, @OldDocumentFlowType_Id) = 0
			SET @ConditionChanged = 1
		ELSE
			SET @ConditionChanged = 0;

		IF @ConditionChanged = 1
			INSERT INTO [Contract].[ClientContractsDetails]([Contract_Id], [DATE], [ExpireDate], [Type_Id], [PayType_Id], [Discount_Id], [ContractPrice], [Comments], [DocumentFlowType_Id])
			VALUES (@Contract_Id, @Date, @ExpireDate, @Type_Id, @PayType_Id, @Discount_Id, @ContractPrice, @Comments, @DocumentFlowType_Id);

		IF @DocumentExists = 1
			INSERT INTO [Contract].[ClientContractsDocuments]([Contract_Id], [RowIndex], [Type_Id], [Date], [Note])
			SELECT
				@Contract_Id,
				IsNull((SELECT Max([RowIndex]) + 1 FROM [Contract].[ClientContractsDocuments] WHERE [Contract_Id] = @Contract_Id), 1),
				@DocumentType_Id, @DocumentDate, @DocumentNote;

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
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_CONDITIONS_CHANGE] TO rl_client_contract_u;
GO
