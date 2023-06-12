USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CLIENT_SPECIFICATION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CLIENT_SPECIFICATION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CLIENT_SPECIFICATION_SELECT]
	@ID	INT
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

		SELECT a.ID, ID_SPECIFICATION, b.NAME, a.NUM, a.REG_DATE, a.DATE, FINISH_DATE, a.RETURN_DATE, a.ID_STATUS, c.IND, a.NOTE
		FROM
			Contract.ContractSpecification a
			INNER JOIN Contract.Contract d ON d.ID = a.ID_CONTRACT
			INNER JOIN Contract.Specification b ON a.ID_SPECIFICATION = b.ID
			INNER JOIN Contract.Status c ON a.ID_STATUS = c.ID
		WHERE ID_CLIENT = @ID
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
GRANT EXECUTE ON [Contract].[CLIENT_SPECIFICATION_SELECT] TO rl_contract_register_r;
GO
