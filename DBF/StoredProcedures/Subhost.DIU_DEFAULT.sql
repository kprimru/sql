USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[DIU_DEFAULT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[DIU_DEFAULT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[DIU_DEFAULT]
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
			SST_ID, SST_CAPTION,
			NULL AS DISTR,
			NULL AS SH_ID, NULL AS SH_CAPTION,
			NULL AS COMMENT,
			CONVERT(BIT, 0) AS UNREG
		FROM dbo.SystemTypeTable
		WHERE SST_NAME = 'NCT'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[DIU_DEFAULT] TO rl_subhost_calc;
GO
