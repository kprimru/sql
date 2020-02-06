USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CONTRACT_FOUNDATION_SAVE]
	@Contract_Id		UniqueIdentifier,
	@Date				SmallDateTime,
	@Foundation_Id		UniqueIdentifier,
	@ExpireDate			SmallDateTime,
	@Note				VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN;
		
		UPDATE Contract.ClientContractsFoundations
		SET [Foundation_Id]	= @Foundation_Id,
			[ExpireDate]	= @ExpireDate,
			[Note]			= @Note
		WHERE	[Contract_Id]	= @Contract_Id
			AND	[DATE]			= @Date;
			
		IF @@RowCount = 0
			INSERT INTO Contract.ClientContractsFoundations([Contract_Id], [DATE], [Foundation_Id], [ExpireDate], [Note])
			VALUES(@Contract_Id, @Date, @Foundation_Id, @ExpireDate, @Note)
		
		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;
			
		EXEC [Maintenance].[ReRaise Error];
	END CATCH;
END
