USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SPECIAL_COEF_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SPECIAL_COEF_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[SPECIAL_COEF_DELETE]
	@System_Id		Int,
	@DistrType_Id	Int,
	@SystemType_Id	Int,
	@PERIOD			UniqueIdentifier
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

		DELETE [Price].[Coef:Special]
		WHERE [System_Id] = @System_Id
			AND [DistrType_Id] = @DistrType_Id
			AND [SystemType_Id] = @SystemType_Id
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
GRANT EXECUTE ON [Price].[SPECIAL_COEF_DELETE] TO rl_price_import;
GO
