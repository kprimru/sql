USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACTIVITY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACTIVITY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACTIVITY_SELECT]
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

		SELECT AC_ID, AC_NAME, AC_CODE, AC_SHORT, AC_CODE + ' ' + ISNULL(AC_SHORT, AC_NAME) AS AC_SEARCH
		FROM dbo.Activity
		WHERE @FILTER IS NULL
			OR AC_NAME LIKE @FILTER
			OR AC_CODE LIKE @FILTER
			OR AC_SHORT LIKE @FILTER
		ORDER BY
			dbo.StringDelimiterPartInt(AC_CODE, '.', 1),
			dbo.StringDelimiterPartInt(AC_CODE, '.', 2),
			dbo.StringDelimiterPartInt(AC_CODE, '.', 3),
			dbo.StringDelimiterPartInt(AC_CODE, '.', 4)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACTIVITY_SELECT] TO rl_activity_r;
GO
