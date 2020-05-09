USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CONTRACT_SPECIFICATION_SELECT]
	@ID	UNIQUEIDENTIFIER
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

		SELECT a.ID, ID_SPECIFICATION, b.NAME, a.NUM, REG_DATE, DATE, FINISH_DATE, RETURN_DATE, a.ID_STATUS, c.IND, a.NOTE
		FROM
			Contract.ContractSpecification a
			INNER JOIN Contract.Specification b ON a.ID_SPECIFICATION = b.ID
			INNER JOIN Contract.Status c ON a.ID_STATUS = c.ID
		WHERE ID_CONTRACT = @ID
		ORDER BY NUM, DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CONTRACT_SPECIFICATION_SELECT] TO rl_contract_register_r;
GO