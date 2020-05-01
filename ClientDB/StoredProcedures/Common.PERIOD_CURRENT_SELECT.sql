USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PERIOD_CURRENT_SELECT]
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
			(
				SELECT TOP 1 ID
				FROM Common.Period
				WHERE GETDATE() BETWEEN START AND DATEADD(DAY, 1, FINISH)
					AND TYPE = 2
			) AS MON,
			(
				SELECT TOP 1 ID
				FROM Common.Period
				WHERE DATEADD(MONTH, 1, GETDATE()) BETWEEN START AND DATEADD(DAY, 1, FINISH)
					AND TYPE = 2
			) AS MON_NEXT,
			(
				SELECT TOP 1 ID
				FROM Common.Period
				WHERE GETDATE() BETWEEN START AND DATEADD(DAY, 1, FINISH)
					AND TYPE = 3
			) AS QUART,
			(
				SELECT TOP 1 ID
				FROM Common.Period
				WHERE GETDATE() BETWEEN START AND DATEADD(DAY, 1, FINISH)
					AND TYPE = 4
			) AS HALF,
			(
				SELECT TOP 1 ID
				FROM Common.Period
				WHERE GETDATE() BETWEEN START AND DATEADD(DAY, 1, FINISH)
					AND TYPE = 5
			) AS YR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Common].[PERIOD_CURRENT_SELECT] TO public;
GO