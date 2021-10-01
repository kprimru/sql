USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[NET_TYPE_SELECT]
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

		SELECT NT_ID, NT_NAME, NT_NOTE, NT_SHORT
		FROM Din.NetType
		WHERE @FILTER IS NULL
			OR NT_NAME LIKE @FILTER
			OR NT_NOTE LIKE @FILTER
		ORDER BY NT_NAME, NT_NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[NET_TYPE_SELECT] TO rl_din_import;
GRANT EXECUTE ON [Din].[NET_TYPE_SELECT] TO rl_din_net_type_r;
GO
