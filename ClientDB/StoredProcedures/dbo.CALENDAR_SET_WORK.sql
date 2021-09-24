USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CALENDAR_SET_WORK]
	@ID	INT
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

		DECLARE @DT	SMALLDATETIME
		DECLARE @WORK	BIT

		SELECT @DT = CalendarDate, @WORK = CalendarWork
		FROM dbo.Calendar
		WHERE CalendarID = @ID

		UPDATE dbo.Calendar
		SET CalendarWork =
				CASE CalendarWork
					WHEN 1 THEN 0
					WHEN 0 THEN 1
					ELSE NULL
				END
		WHERE CalendarID = @ID

		UPDATE dbo.Calendar
		SET CalendarIndex = CalendarIndex +
				CASE @WORK
					WHEN 1 THEN -1
					WHEN 0 THEN 1
					ELSE 0
				END
		WHERE CalendarDate >= @DT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALENDAR_SET_WORK] TO rl_calendar_u;
GO
