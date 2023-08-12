USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_SCHEDULE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_SCHEDULE_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[WEB_SCHEDULE_SELECT]
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
			S.[ID], S.[LIMIT], CONVERT(NVarChar(32), S.[DATE], 104) + ' ' + LEFT(Convert(NVarCHar(32), S.[TIME], 108), 5) + ' ' + [Seminar].[SubjectNameView](J.[NAME], T.[Name]) AS SUBJ_FULL,
			S.[DATE], S.[TIME],
			--J.[NOTE],
			[NOTE] = [Seminar].[SubjectNoteView](J.[NOTE], S.[DATE], S.[TIME], T.[PlaceTemplate]),
			J.[READER], S.[QUESTIONS], S.[PERSONAL]
		FROM [Seminar].[Schedule]				AS S
		INNER JOIN [Seminar].[Subject]			AS J ON J.[ID] = S.[ID_SUBJECT]
		LEFT JOIN [Seminar].[Schedules->Types]	AS T ON T.Id = S.[Type_Id]
		WHERE S.[WEB] = 1
			AND S.[DATE] >= GETDATE()
		ORDER BY S.[DATE]

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
