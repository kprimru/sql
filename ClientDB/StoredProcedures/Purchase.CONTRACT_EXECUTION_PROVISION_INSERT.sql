USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CONTRACT_EXECUTION_PROVISION_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CONTRACT_EXECUTION_PROVISION_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[CONTRACT_EXECUTION_PROVISION_INSERT]
	@NAME	VARCHAR(250),
	@SHORT	VARCHAR(50),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.ContractExecutionProvision(CEP_NAME, CEP_SHORT)
			OUTPUT inserted.CEP_ID INTO @TBL
			VALUES(@NAME, @SHORT)

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CONTRACT_EXECUTION_PROVISION_INSERT] TO rl_contract_execution_provision_i;
GO
