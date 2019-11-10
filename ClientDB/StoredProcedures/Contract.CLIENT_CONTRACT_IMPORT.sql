USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_IMPORT]
	@Client_Id			Int,
	@Contract_Id		UniqueIdentifier,
	@DateFrom			SmallDateTime,
	@ExpireDate			SmallDateTime,
	@Type_Id			Int,
	@PayType_Id			Int,
	@Discount_Id		Int,
	@ContractPrice		Money,
	@Comments			VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN;
		
		IF EXISTS(SELECT * FROM [Contract].[ClientContracts] WHERE [Client_Id] = @Client_Id AND [Contract_Id] = @Contract_Id)
		BEGIN
			RaisError('Ошибка! Выбранный договор уже присутствует у клиента', 16, 1);
		
			RETURN;
		END;
		
		INSERT INTO [Contract].[ClientContracts]([Client_Id], [Contract_Id])
		VALUES(@Client_Id, @Contract_Id);
		
		IF NOT EXISTS(SELECT * FROM [Contract].[ClientContractsDetails] WHERE [Contract_Id] = @Contract_Id)
		BEGIN
			-- договора еще нет, это первое добавление - заполняем детализацию договора
			UPDATE [Contract].[Contract]
			SET [DateFrom] = @DateFrom
			WHERE [ID] = @Contract_Id
				AND [DateFrom] IS NULL;
				
			IF @@RowCount != 1
				RaisError('Внутренняя ошибка! DateFrom IS NOT NULL', 16, 1);
				
			INSERT INTO [Contract].[ClientContractsDetails]([Contract_Id], [DATE], [ExpireDate], [Type_Id], [PayType_Id], [Discount_Id], [ContractPrice], [Comments])
			VALUES (@Contract_Id, @DateFrom, @ExpireDate, @Type_Id, @PayType_Id, @Discount_Id, @ContractPrice, @Comments);
		END;
		
		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	
		IF @@TranCount > 0
			ROLLBACK TRAN;
	END CATCH;
END
