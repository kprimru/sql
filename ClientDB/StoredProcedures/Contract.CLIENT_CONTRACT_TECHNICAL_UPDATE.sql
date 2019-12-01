USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_TECHNICAL_UPDATE]
	@Contract_Id		UniqueIdentifier,
	@Date				SmallDateTime,
	@ExpireDate			SmallDateTime,
	@Type_Id			Int,
	@PayType_Id			Int,
	@Discount_Id		Int,
	@ContractPrice		Money,
	@Comments			VarChar(Max),
	@DateFrom			SmallDateTime,
	@DateTo				SmallDateTime
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN;
		
		UPDATE [Contract].[Contract]
		SET [DateFrom]	= @DateFrom,
			[DateTo]	= @DateTo
		WHERE [Id] = @Contract_Id;
		
		UPDATE [Contract].[ClientContractsDetails]
		SET [ExpireDate]	= @ExpireDate,
			[Type_Id]		= @Type_Id,
			[PayType_Id]	= @PayType_Id,
			[Discount_Id]	= @Discount_Id,
			[ContractPrice] = @ContractPrice,
			[Comments]		= @Comments
		WHERE [Contract_Id] = @Contract_Id
			AND [DATE] = @Date
		
		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	
		IF @@TranCount > 0
			ROLLBACK TRAN;
	END CATCH;
END
