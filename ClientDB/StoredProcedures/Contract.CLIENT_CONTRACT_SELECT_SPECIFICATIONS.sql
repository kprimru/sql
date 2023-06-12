USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_CONTRACT_SELECT_SPECIFICATIONS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_SPECIFICATIONS]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_SPECIFICATIONS]
	@Contract_Id	UniqueIdentifier,
	@HideUnsigned	Bit					= 0
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

		SELECT
		    CS.ID, CS.NUM, CS.DATE, CS.FINISH_DATE, CS.NOTE, S.NAME, [Code] = S.[NUM], CS.Comment, CS.DateFrom, CS.DateTo, CS.SignDate,
		    [IsActive] = Cast(CASE WHEN CS.SignDate IS NOT NULL AND CS.DateTo IS NULL THEN 1 ELSE 0 END AS Bit)
		FROM Contract.ContractSpecification AS CS
		INNER JOIN Contract.Specification	AS S ON CS.ID_SPECIFICATION = S.ID
		WHERE ID_CONTRACT = @Contract_Id
			AND (@HideUnsigned = 0 OR @HideUnsigned = 1 AND CS.SignDate IS NOT NULL)
		ORDER BY CS.DATE DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_SELECT_SPECIFICATIONS] TO rl_client_contract_r;
GO
