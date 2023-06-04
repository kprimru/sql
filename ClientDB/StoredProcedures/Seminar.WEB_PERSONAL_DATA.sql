USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_PERSONAL_DATA]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_PERSONAL_DATA]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[WEB_PERSONAL_DATA]
	@ID	UNIQUEIDENTIFIER
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
			PSEDO,
			[SEMINAR] = [Seminar].[SubjectNameView](c.Name, T.name),
			CONVERT(NVARCHAR(64), b.DATE, 104) + ' в ' + LEFT(CONVERT(NVARCHAR(64), b.TIME, 108), 5) AS DATE,
			a.CONFIRM_STATUS
		FROM
			Seminar.Personal a
			INNER JOIN Seminar.Schedule b ON a.ID_SCHEDULE = b.ID
			INNER JOIN Seminar.Subject c ON b.ID_SUBJECT = c.ID
			LEFT JOIN Seminar.[Schedules->Types] AS T ON t.[Id] = b.[Type_Id]
		WHERE a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_PERSONAL_DATA] TO rl_seminar_web;
GO
