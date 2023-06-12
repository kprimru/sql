USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SYSTEM_TYPE_COEF_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SYSTEM_TYPE_COEF_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[SYSTEM_TYPE_COEF_DELETE]
	@TYPE		Int,
	@PERIOD		UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = [START]
		FROM [Common].[Period]
		WHERE [ID] = @PERIOD;

		DELETE [Price].[SystemType:Coef]
		WHERE [SystemType_Id] = @TYPE
			AND [Date] = @Date;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[SYSTEM_TYPE_COEF_DELETE] TO rl_price_import;
GO
