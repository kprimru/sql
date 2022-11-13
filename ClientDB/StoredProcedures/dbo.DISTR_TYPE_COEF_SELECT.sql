USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_TYPE_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_TYPE_COEF_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_TYPE_COEF_SELECT]
	@NET		Int,
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

		SELECT P.[ID], P.[NAME], C.[DistrTypeName], a.[Coef], a.[Round], a.[Date], c.[DistrTypeID]
		FROM [Price].[DistrType:Coef]		AS a
		INNER JOIN [dbo].[DistrTypeTable]	AS c ON c.[DistrTypeID] = a.[DistrType_Id]
		INNER JOIN [Common].[Period]		AS P ON P.[START] = a.[Date] AND P.[TYPE] = 2
		WHERE (a.[DistrType_Id] = @NET OR @NET IS NULL)
		ORDER BY a.[Date] DESC, c.[DistrTypeOrder];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_TYPE_COEF_SELECT] TO rl_distr_type_u;
GO
