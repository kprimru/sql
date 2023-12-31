USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
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

		SELECT DistrTypeID, DistrTypeName, DistrTypeOrder, DistrTypeFull, DistrTypeCode, DistrTypeBaseCheck
		FROM dbo.DistrTypeTable
		WHERE @FILTER IS NULL
			OR DistrTypeName LIKE @FILTER
			OR DistrTypeFull LIKE @FILTER
			OR DistrTypeCode LIKE @FILTER
		ORDER BY DistrTypeOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_TYPE_SELECT] TO rl_distr_type_r;
GO
