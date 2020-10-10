USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[SystemType@Select?Synonyms]
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

		SELECT SST_ID, S.SST_NAME, S.SST_NOTE, SST_SHORT, SST_WEIGHT, SST_REG
		FROM Din.SystemType AS T
		INNER JOIN Din.[SystemType:Synonyms] AS S ON T.SST_ID = S.Type_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[SystemType@Select?Synonyms] TO rl_din_import;
GRANT EXECUTE ON [Din].[SystemType@Select?Synonyms] TO rl_din_system_type_r;
GO