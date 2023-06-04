USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[STUDY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[STUDY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[STUDY_SELECT]
	@ID		UNIQUEIDENTIFIER
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
			a.DATE,
			[Subject] = [Seminar].[SubjectNameView](b.NAME, T.Name),
			ID_CLIENT, ClientFullName, SURNAME, c.NAME, PATRON, POSITION,
			CONVERT(BIT,
				CASE c.STUDY
					WHEN 1 THEN 0
					ELSE
						CASE INDX
							WHEN 1 THEN 1
							ELSE 0
						END
				END
			) AS CHECKED,
			c.ID
		FROM Seminar.Schedule a
		INNER JOIN Seminar.Subject b ON a.ID_SUBJECT = b.ID
		INNER JOIN Seminar.Personal c ON a.ID = c.ID_SCHEDULE
		INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
		INNER JOIN Seminar.Status d ON d.ID = c.ID_STATUS
		LEFT JOIN Seminar.[Schedules->Types] AS T ON T.[Id] = A.[Type_Id]
		WHERE a.ID = @ID AND c.STATUS = 1
		ORDER BY CHECKED DESC, ClientFullName, SURNAME, NAME, PATRON

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[STUDY_SELECT] TO rl_seminar_study;
GO
