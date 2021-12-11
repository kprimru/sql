USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTRACT_FOUNDATION_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTRACT_FOUNDATION_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CONTRACT_FOUNDATION_GET]
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

		SELECT NAME
		FROM dbo.ContractFoundation
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_FOUNDATION_GET] TO rl_contract_foundation_d;
GRANT EXECUTE ON [dbo].[CONTRACT_FOUNDATION_GET] TO rl_contract_foundation_u;
GO
