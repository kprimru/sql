USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[PERIOD_MONTH_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[PERIOD_MONTH_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Common].[PERIOD_MONTH_SELECT]
	@FILTER	NVARCHAR(200) = NULL
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

		SELECT ID, NAME, START, FINISH
		FROM Common.Period
		WHERE TYPE = 2
			AND ACTIVE = 1
			AND (NAME LIKE @FILTER OR @FILTER IS NULL)
		ORDER BY START DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Common].[PERIOD_MONTH_SELECT] TO rl_period_r;
GO
