USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_SPECIFICATIONS]
	@Contract_Id	UniqueIdentifier
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

		SELECT CS.ID, CS.NUM, CS.DATE, CS.FINISH_DATE, CS.NOTE, S.NAME
		FROM Contract.ContractSpecification AS CS
		INNER JOIN Contract.Specification	AS S ON CS.ID_SPECIFICATION = S.ID
		WHERE ID_CONTRACT = @Contract_Id
		ORDER BY CS.DATE DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_SELECT_SPECIFICATIONS] TO rl_client_contract_r;
GO