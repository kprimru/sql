USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CALENDAR_WORK_SELECT]
	@YEAR	UNIQUEIDENTIFIER,
	@TP		NVARCHAR(MAX),
	@SEARCH	NVARCHAR(256) = NULL
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

		SELECT a.ID, a.DATE, b.NAME AS TP_NAME, a.NAME, a.NOTE, DATEPART(MONTH, DATE) AS MON_NUM, DATEPART(DAY, DATE) AS DAY_NUM, CONVERT(NVARCHAR(32), DATE, 112) AS DATE_S
		FROM
			dbo.CalendarDate a
			INNER JOIN dbo.CalendarType b ON a.ID_TYPE = b.ID
			INNER JOIN Common.Period c ON c.ID = @YEAR AND c.START <= DATE AND c.FINISH >= DATE
		WHERE a.STATUS = 1
			AND (@TP IS NULL OR ID_TYPE IN (SELECT ID FROM dbo.TableGUIDFromXML(@TP)))
			AND
				(
					@SEARCH IS NULL
					OR a.NAME LIKE @SEARCH
					OR NOTE LIKE @SEARCH
				)
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALENDAR_WORK_SELECT] TO rl_work_calendar_r;
GO