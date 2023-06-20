USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[DISTR_TYPE_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[DISTR_TYPE_COEF_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[DISTR_TYPE_COEF_SELECT]
	@NET		Int = NULL,
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

		SELECT
			C.[DistrType_Id],
			--D.[DistrTypeName],
			C.[Date],
			C.[Coef],
			C.[Round]
		FROM [Price].[DistrType:Coef]		AS C
		INNER JOIN [dbo].[DistrTypeTable]	AS D ON D.[DistrTypeID] = C.[DistrType_Id]
		WHERE (C.[DistrType_Id] = @NET OR @NET IS NULL)
		ORDER BY
			D.[DistrTypeOrder],
			C.[Date] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Price].[DISTR_TYPE_COEF_SELECT] TO rl_price_r;
GO
