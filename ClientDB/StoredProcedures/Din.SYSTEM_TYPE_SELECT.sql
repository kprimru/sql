USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[SYSTEM_TYPE_SELECT]
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

		SELECT SST_ID, SST_NAME, SST_NOTE, SST_SHORT, SST_WEIGHT, SST_REG
		FROM Din.SystemType
		WHERE @FILTER IS NULL
			OR SST_NAME LIKE @FILTER
			OR SST_SHORT LIKE @FILTER
			OR SST_REG LIKE @FILTER
			OR SST_NOTE LIKE @FILTER
		ORDER BY SST_NAME, SST_NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[SYSTEM_TYPE_SELECT] TO rl_din_import;
GRANT EXECUTE ON [Din].[SYSTEM_TYPE_SELECT] TO rl_din_system_type_r;
GO
