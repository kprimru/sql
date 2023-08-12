USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SPECIAL_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SPECIAL_COEF_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Price].[SPECIAL_COEF_SELECT]
	@System_Id		Int = NULL,
	@DistrType_Id	Int = NULL,
	@SystemType_Id	Int = NULL
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
			C.[Coef], C.[Round], C.[Date],
			C.[SystemType_Id], C.[System_Id], C.[DistrType_Id]
		FROM [Price].[Coef:Special]			AS C
		WHERE (C.[System_Id] = @System_Id OR @System_Id IS NULL)
			AND (C.[DistrType_Id] = @DistrType_Id OR @DistrType_Id IS NULL)
			AND (C.[SystemType_Id] = @SystemType_Id OR @SystemType_Id IS NULL)
		---
		UNION ALL
		---
		SELECT
			C.[Coef], C.[Round], C.[Date],
			NULL, C.[System_Id], C.[DistrType_Id]
		FROM [Price].[Coef:Special:Common]			AS C
		WHERE (C.[System_Id] = @System_Id OR @System_Id IS NULL)
			AND (C.[DistrType_Id] = @DistrType_Id OR @DistrType_Id IS NULL)
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
