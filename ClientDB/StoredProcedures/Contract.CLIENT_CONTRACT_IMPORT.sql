USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_IMPORT]
	@Client_Id			Int,
	@Contract_Id		UniqueIdentifier,
	@DateFrom			SmallDateTime,
	@SignDate			SmallDateTime,
	@ExpireDate			SmallDateTime,
	@Type_Id			Int,
	@PayType_Id			Int,
	@Discount_Id		Int,
	@ContractPrice		Money,
	@Comments			VarChar(Max)
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

		IF EXISTS(SELECT * FROM [Contract].[ClientContracts] WHERE [Client_Id] = @Client_Id AND [Contract_Id] = @Contract_Id)
		BEGIN
			RaisError('ќшибка! ¬ыбранный договор уже присутствует у клиента', 16, 1);

			RETURN;
		END;

		INSERT INTO [Contract].[ClientContracts]([Client_Id], [Contract_Id])
		VALUES(@Client_Id, @Contract_Id);

		IF NOT EXISTS(SELECT * FROM [Contract].[ClientContractsDetails] WHERE [Contract_Id] = @Contract_Id)
		BEGIN
			-- договора еще нет, это первое добавление - заполн€ем детализацию договора
			UPDATE [Contract].[Contract]
			SET [DateFrom]	= @DateFrom,
				[SignDate]	= @SignDate
			WHERE [ID] = @Contract_Id
				AND [DateFrom] IS NULL;

			INSERT INTO [Contract].[ClientContractsDetails]([Contract_Id], [DATE], [ExpireDate], [Type_Id], [PayType_Id], [Discount_Id], [ContractPrice], [Comments])
			VALUES (@Contract_Id, @DateFrom, @ExpireDate, @Type_Id, @PayType_Id, @Discount_Id, @ContractPrice, @Comments);
		END;

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
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_IMPORT] TO rl_client_contract_u;
GO