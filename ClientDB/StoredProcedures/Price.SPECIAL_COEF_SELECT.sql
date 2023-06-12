USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SPECIAL_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SPECIAL_COEF_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[SPECIAL_COEF_SELECT]
	@System_Id		Int,
	@DistrType_Id	Int,
	@SystemType_Id	Int
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

		SELECT
			P.[NAME], C.[Coef], C.[Round], C.[Date],
			C.[SystemType_Id], C.[System_Id], C.[DistrType_Id], [Period_Id] = P.[ID]
		FROM [Price].[Coef:Special]			AS C
		INNER JOIN [Common].[Period]		AS P ON P.[START] = C.[Date] AND P.[TYPE] = 2
		WHERE (C.[System_Id] = @System_Id OR @System_Id IS NULL)
			AND (C.[DistrType_Id] = @DistrType_Id OR @DistrType_Id IS NULL)
			AND (C.[SystemType_Id] = @SystemType_Id OR @SystemType_Id IS NULL)
		ORDER BY C.[Date] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Price].[SPECIAL_COEF_SELECT] TO rl_price_r;
GO
