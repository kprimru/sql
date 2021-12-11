USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CALENDAR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CALENDAR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CALENDAR_SELECT]
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@WEEK_DAY	INT = NULL,
	@HOLIDAY	BIT = 0
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

		SELECT CalendarID, CalendarDate, DayName, CalendarWork
		FROM
			dbo.Calendar
			INNER JOIN dbo.DayTable ON DayID = CalendarWeekDayID
		WHERE (CalendarDate >= @BEGIN OR @BEGIN IS NULL)
			AND (CalendarDate <= @END OR @END IS NULL)
			AND (CalendarWeekDayID = @WEEK_DAY OR @WEEK_DAY IS NULL)
			AND (CalendarWork = 0 OR @HOLIDAY <> 1)
		ORDER BY CalendarDate

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALENDAR_SELECT] TO rl_calendar_r;
GO
