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

		INSERT INTO [Price].[System:Price]([System_Id], [Date], [Price])
		SELECT @SYSTEM, P.[START], @PRICE
		FROM [Common].[Period] AS P
		WHERE [ID] = @MONTH
			AND NOT EXISTS
				(
					SELECT *
					FROM [Price].[System:Price]
					WHERE [System_Id] = @SYSTEM
						AND [Date] = P.[START]
				);

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
