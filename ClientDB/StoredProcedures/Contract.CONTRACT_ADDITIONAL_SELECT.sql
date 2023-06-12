USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CONTRACT_ADDITIONAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CONTRACT_ADDITIONAL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CONTRACT_ADDITIONAL_SELECT]
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

		SELECT ID, NUM, REG_DATE, DATE, RETURN_DATE, a.NOTE
		FROM
			Contract.Additional a
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
GRANT EXECUTE ON [Contract].[CONTRACT_ADDITIONAL_SELECT] TO rl_contract_register_r;
GO
