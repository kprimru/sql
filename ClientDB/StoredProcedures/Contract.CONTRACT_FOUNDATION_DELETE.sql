USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CONTRACT_FOUNDATION_DELETE]
	@Contract_Id		UniqueIdentifier,
	@Date				SmallDateTime
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN;
		
		DELETE
		FROM Contract.ClientContractsFoundations
		WHERE	[Contract_Id]	= @Contract_Id
			AND	[DATE]			= @Date;

		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	
		IF @@TranCount > 0
			ROLLBACK TRAN;
	END CATCH;
END
