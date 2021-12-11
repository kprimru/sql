USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTRACT_PAY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTRACT_PAY_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CONTRACT_PAY_DELETE]
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

		DELETE
		FROM dbo.ContractPayTable
		WHERE ContractPayID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_PAY_DELETE] TO rl_contract_pay_d;
GO
