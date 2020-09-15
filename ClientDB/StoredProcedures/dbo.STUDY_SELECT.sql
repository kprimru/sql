USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_SELECT]
	@CLIENT	INT
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

		IF OBJECT_ID('tempdb..#study') IS NOT NULL
			DROP TABLE #study

		CREATE TABLE #study
			(
				ID			UNIQUEIDENTIFIER,
				MST			UNIQUEIDENTIFIER,
				ID_STUDY	UNIQUEIDENTIFIER,
				DATE		SMALLDATETIME,
				PLACE		NVARCHAR(64),
				PERS		NVARCHAR(256),
				TEACHED		BIT,
				STUDY_TYPE	NVARCHAR(128),
				NEED		NVARCHAR(MAX),
				RECOMEND	NVARCHAR(MAX),
				NOTE		NVARCHAR(MAX),
				POSITION	NVARCHAR(256),
				SERTIFICAT	NVARCHAR(MAX),
				UPD_DATE	DATETIME,
				RIVAL		NVARCHAR(MAX),
				AGREEMENT   BIT
			)

		INSERT INTO #study(ID, ID_STUDY, DATE, PLACE, PERS, NOTE, NEED, RECOMEND, TEACHED, STUDY_TYPE, RIVAL, AGREEMENT, UPD_DATE)
		SELECT
			NEWID(), a.ID, DATE, LessonPlaceName, TeacherName, NOTE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SystemShortName + ','
					FROM
						dbo.ClientStudySystem z
						INNER JOIN dbo.SystemTable y ON z.ID_SYSTEM = y.SystemID
					WHERE z.ID_STUDY = a.ID
					ORDER BY systemorder FOR XML PATH('')
				)

			), 1, 1, '')) + CHAR(10) + NEED AS NEED,
			RECOMEND, TEACHED, b.NAME, RIVAL, AGREEMENT,
			(
				SELECT MIN(UPD_DATE)
				FROM dbo.ClientStudy z
				WHERE z.ID = a.ID OR z.ID_MASTER = a.ID
			) AS UPD_DATE
		FROM dbo.ClientStudy a
		LEFT OUTER JOIN dbo.TeacherTable ON TeacherID = ID_TEACHER
		LEFT OUTER JOIN dbo.LessonPlaceTable ON LessonPlaceID = ID_PLACE
		LEFT OUTER JOIN dbo.StudyType b ON b.ID = a.ID_TYPE
		WHERE ID_CLIENT = @CLIENT AND STATUS = 1
		ORDER BY DATE DESC, ID DESC

		INSERT INTO #study(ID, MST, ID_STUDY, PERS, POSITION, SERTIFICAT, NOTE, NEED, RECOMEND, TEACHED, STUDY_TYPE, UPD_DATE)
			SELECT
				NEWID(),
				b.ID, b.ID_STUDY, ISNULL(SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(PATRON, '')
					+ CASE
							WHEN ISNULL(GR_COUNT, 1) = 1 THEN ''
							ELSE ' (' + CONVERT(NVARCHAR(32), GR_COUNT) + ')'
						END,
				a.POSITION, c.NAME, b.NOTE,
				b.NEED AS NEED,  b.RECOMEND, b.TEACHED, b.STUDY_TYPE,
				(
					SELECT MIN(UPD_DATE)
					FROM dbo.ClientStudy z
					WHERE z.ID = a.ID_STUDY OR z.ID_MASTER = a.ID_STUDY
				) AS UPD_DATE
			FROM
				dbo.ClientStudyPeople a
				INNER JOIN #study b ON a.ID_STUDY = b.ID_STUDY
				LEFT OUTER JOIN dbo.SertificatType c ON c.ID = a.ID_SERT_TYPE
			ORDER BY 3

		SELECT
		    ID, MST, ID_STUDY,
		    DATE, PLACE, PERS, TEACHED, NEED, RECOMEND, NOTE, POSITION, SERTIFICAT, STUDY_TYPE, RIVAL,
		    CASE WHEN MST IS NULL THEN CASE AGREEMENT WHEN 1 THEN '��' ELSE '���' END END AS AGREEMENT,
		    UPD_DATE
		FROM #study
		ORDER BY DATE DESC, PERS

		IF OBJECT_ID('tempdb..#study') IS NOT NULL
			DROP TABLE #study

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_SELECT] TO rl_client_study_r;
GO