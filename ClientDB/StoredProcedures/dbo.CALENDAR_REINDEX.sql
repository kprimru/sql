USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CALENDAR_REINDEX]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CALENDAR_REINDEX]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CALENDAR_REINDEX]
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

		DECLARE @INDEX	INT
		DECLARE	@MIN_DT	SMALLDATETIME
		DECLARE	@MAX_DT	SMALLDATETIME

		SELECT
			@MIN_DT = MIN(CalendarDate),
			@MAX_DT = MAX(CalendarDate),
			@INDEX = 1
		FROM
			dbo.Calendar

		WHILE @MIN_DT <= @MAX_DT
		BEGIN
			IF (
					SELECT CalendarWork
					FROM dbo.Calendar
					WHERE CalendarDate = @MIN_DT
				) = 1
				SET @INDEX = @INDEX + 1

			UPDATE dbo.Calendar
			SET CalendarIndex = @INDEX
			WHERE CalendarDate = @MIN_DT

			SET @MIN_DT = DATEADD(DAY, 1, @MIN_DT)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
