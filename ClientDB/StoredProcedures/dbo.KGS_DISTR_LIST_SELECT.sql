USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[KGS_DISTR_LIST_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[KGS_DISTR_LIST_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[KGS_DISTR_LIST_SELECT]
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

		SELECT KDL_ID, KDL_NAME
		FROM dbo.KGSDistrList
		WHERE @FILTER IS NULL
			OR KDL_NAME LIKE @FILTER
			OR EXISTS
				(
					SELECT *
					FROM dbo.KGSDistr
					WHERE KD_ID_LIST = KDL_ID
						AND CONVERT(VARCHAR(20), KD_DISTR) LIKE @FILTER
				)
		ORDER BY KDL_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[KGS_DISTR_LIST_SELECT] TO rl_kgs_distr_r;
GO
