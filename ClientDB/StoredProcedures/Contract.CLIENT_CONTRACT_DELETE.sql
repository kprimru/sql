USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_DELETE]
	@ID	UniqueIdentifier
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;

		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_DELETE] TO rl_client_contract_d;
GO
