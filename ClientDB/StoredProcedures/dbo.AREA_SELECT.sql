USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[AREA_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[AREA_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[AREA_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT AR_ID, AR_NAME, RG_NAME, AR_PREFIX, AR_SUFFIX
		FROM
			dbo.Area
			INNER JOIN dbo.Region ON RG_ID = AR_ID_REGION
		WHERE @FILTER IS NULL
			OR AR_NAME LIKE @FILTER
			OR RG_NAME LIKE @FILTER
			OR CONVERT(VARCHAR(20), RG_NUM) LIKE @FILTER
		ORDER BY AR_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[AREA_SELECT] TO rl_area_r;
GO
