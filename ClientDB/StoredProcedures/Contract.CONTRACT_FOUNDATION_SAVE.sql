USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CONTRACT_FOUNDATION_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CONTRACT_FOUNDATION_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CONTRACT_FOUNDATION_SAVE]
	@Contract_Id		UniqueIdentifier,
	@Date				SmallDateTime,
	@Foundation_Id		UniqueIdentifier,
	@ExpireDate			SmallDateTime,
	@Note				VarChar(Max)
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		IF @@TranCount > 0
			ROLLBACK TRAN;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH;
END
GO
GRANT EXECUTE ON [Contract].[CONTRACT_FOUNDATION_SAVE] TO rl_client_contract_foundation;
GO
