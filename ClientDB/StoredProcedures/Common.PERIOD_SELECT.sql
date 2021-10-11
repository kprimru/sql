USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PERIOD_SELECT]
	@TYPE	TINYINT,
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@FILTER	VARCHAR(100) = NULL,
	@ACTIVE BIT = NULL
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

		SELECT ID, NAME, START, FINISH, ACTIVE
		FROM Common.Period
		WHERE (ACTIVE = 1 AND @ACTIVE IS NULL OR @ACTIVE = 1 OR @ACTIVE = 0 AND ACTIVE = 1)
			AND TYPE = @TYPE
			AND (START >= @BEGIN OR @BEGIN IS NULL)
			AND (FINISH <= @END OR @END IS NULL)
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
GRANT EXECUTE ON [Common].[PERIOD_SELECT] TO public;
GRANT EXECUTE ON [Common].[PERIOD_SELECT] TO rl_period_r;
GO
