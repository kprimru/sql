USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_SCHEDULE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_SCHEDULE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[WEB_SCHEDULE_SELECT]
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
			a.ID, LIMIT, CONVERT(NVARCHAR(32), DATE, 104) + ' ' + LEFT(CONVERT(NVARCHAR(32), TIME, 108), 5) + ' ' + [Seminar].[SubjectNameView](b.NAME, t.Name) AS SUBJ_FULL,
			DATE, TIME, NOTE, READER, a.QUESTIONS, a.PERSONAL
		FROM [Seminar].[Schedule] a
		INNER JOIN [Seminar].[Subject] b ON a.[ID_SUBJECT] = b.[ID]
		LEFT JOIN [Seminar].[Schedules->Types] AS t ON t.Id = a.[Type_Id]
		WHERE a.[WEB] = 1
			AND [DATE] >= GETDATE()
		ORDER BY a.[DATE]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_SCHEDULE_SELECT] TO rl_seminar_web;
GO
