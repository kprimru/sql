USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[PRICE_INSERT]
	@MONTH	UNIQUEIDENTIFIER,
	@SYSTEM	INT,
	@PRICE	MONEY
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

		INSERT INTO Price.SystemPrice(ID_MONTH, ID_SYSTEM, PRICE)
			SELECT @MONTH, @SYSTEM, @PRICE
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Price.SystemPrice
					WHERE ID_SYSTEM = @SYSTEM AND ID_MONTH = @MONTH
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_INSERT] TO rl_price_import;
GO
