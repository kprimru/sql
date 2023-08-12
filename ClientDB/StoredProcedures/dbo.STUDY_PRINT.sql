USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_PRINT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[STUDY_PRINT]
	@CLIENT INT
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
			CONVERT(VARCHAR(20), DATE, 104) AS StudyDateStr,
			LessonPlaceName, TeacherName, '' AS OwnershipName, NEED AS SystemNeed, RECOMEND AS Recomend, NOTE AS StudyNote,
			NULL AS RepeatDate, TEACHED AS Teached, a.RIVAL, a.AGREEMENT,
			REVERSE(
				STUFF(
					REVERSE(
						(
							SELECT
								ISNULL(SURNAME, '') + ' ' + ISNULL(e.NAME, '') + ' ' + ISNULL(PATRON, '') + ' ' +
								'(Дожность: ' + ISNULL(POSITION, 'Нет') + 
								'; Сертификат: ' + CASE ISNULL(LTRIM(RTRIM(f.NAME)), '') WHEN '' THEN 'Нет' ELSE f.NAME END +
								'; № занятия: ' + ISNULL(CONVERT(VARCHAR(20), NUM), 'Нет') +
								'; кол-во обученых: ' + ISNULL(CONVERT(VARCHAR(20), GR_COUNT), '1') + ')' + CHAR(10)
							FROM
								dbo.ClientStudyPeople e
								LEFT OUTER JOIN dbo.SertificatType f ON e.ID_SERT_TYPE = f.ID
							WHERE e.ID_STUDY = a.ID
							ORDER BY SURNAME, e.NAME, PATRON FOR XML PATH('')
						)
							), 1, 1, ''))	AS Students
		FROM
			dbo.ClientStudy a
			LEFT OUTER JOIN dbo.LessonPlaceTable b ON a.ID_PLACE = b.LessonPlaceID
			LEFT OUTER JOIN dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER 
		WHERE ID_CLIENT = @CLIENT AND STATUS = 1
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
GRANT EXECUTE ON [dbo].[STUDY_PRINT] TO rl_client_study_r;
GO
