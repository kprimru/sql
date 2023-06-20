USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SYSTEM_TYPE_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SYSTEM_TYPE_COEF_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[SYSTEM_TYPE_COEF_SELECT]
	@TYPE		Int,
	@PERIOD		UniqueIdentifier = NULL
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

		SELECT C.[SystemType_Id], C.[Coef], C.[Round], C.[Date]
		FROM [Price].[SystemType:Coef]		AS C
		WHERE (C.[SystemType_Id] = @TYPE OR @TYPE IS NULL)
		ORDER BY
			C.[SystemType_Id], C.[Date] DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Price].[SYSTEM_TYPE_COEF_SELECT] TO rl_price_r;
GO
