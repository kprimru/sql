USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[PRICE_DELETE]
	@MONTH	UNIQUEIDENTIFIER,
	@SYSTEM	INT
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
		FROM Price.SystemPrice
		WHERE ID_SYSTEM = @SYSTEM AND ID_MONTH = @MONTH

		DELETE
		FROM [Price].[System:Price]
		WHERE [System_Id] = @SYSTEM
			AND [Date] = (SELECT [START] FROM [Common].[Period] WHERE [ID] = @MONTH);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_DELETE] TO rl_price_import;
GO
