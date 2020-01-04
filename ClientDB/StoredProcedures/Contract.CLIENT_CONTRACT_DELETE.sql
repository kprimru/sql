USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_DELETE]
	@ID	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN;
		
		DELETE
		FROM Contract.ClientContractsFoundations
		WHERE Contract_ID = @ID

		DELETE
		FROM Contract.ClientContractsDocuments
		WHERE Contract_ID = @ID

		DELETE
		FROM Contract.ClientContractsDetails
		WHERE Contract_ID = @ID

		DELETE
		FROM Contract.ClientContracts
		WHERE Contract_ID = @ID
		
		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;
			
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END