USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STUDY_CLAIM_MEETING_REPORT_PRINT_2]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		SET @END = DATEADD(DAY, 1, @END)

		IF OBJECT_ID('tempdb..#claim') IS NOT NULL
			DROP TABLE #claim

		CREATE TABLE #claim
			(
				TeacherName		VARCHAR(150),
				MEETING_DATE	DATETIME,
				MEETING_NOTE	NVARCHAR(MAX),
				ClientName		VARCHAR(500),
				STATUS			TINYINT
			)

		INSERT INTO #claim(TeacherName, MEETING_DATE, MEETING_NOTE, ClientName, STATUS)
			SELECT TeacherName, MEETING_DATE, MEETING_NOTE, ClientFullName + ' (' + CA_STR + ')', STATUS
			FROM
				(
					SELECT MEETING_DATE, TeacherName, MEETING_NOTE, ClientFullName, CA_STR, a.STATUS
					FROM
						dbo.ClientStudyClaim a
						INNER JOIN dbo.TeacherTable ON TeacherID = ID_TEACHER
						INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
						INNER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ID_CLIENT
					WHERE a.STATUS IN (1, 5)

					UNION ALL

					SELECT b.DATE, TeacherName, b.NOTE, ClientFullName, CA_STR, 1
					FROM
						dbo.ClientStudyClaim a
						INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
						INNER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ID_CLIENT
						INNER JOIN dbo.ClientStudyClaimWork b ON a.ID = b.ID_CLAIM
						INNER JOIN dbo.TeacherTable ON TEACHER = TeacherLogin
					WHERE a.STATUS IN (1, 5) AND TP = 1 AND b.STATUS = 1
				) AS o_O
			WHERE MEETING_DATE >= @BEGIN
				AND MEETING_DATE < @END

		IF OBJECT_ID('tempdb..#days') IS NOT NULL
			DROP TABLE #days

		CREATE TABLE #days
			(
				DATE	SMALLDATETIME,
				NAME	NVARCHAR(128)
			)

		INSERT INTO #days(DATE, NAME)
			SELECT CalendarDate, DayName
			FROM
				dbo.Calendar
				INNER JOIN dbo.DayTable ON DayID = CalendarWeekDayID
			WHERE CalendarDate >= @BEGIN AND CalendarDate < @END

		SELECT DISTINCT
			DATE,
			CONVERT(VARCHAR(20), DATE, 104) + CHAR(10) + '(' + NAME + ')' AS DATE_S, TeacherName,
			CASE
				WHEN MET_DATE_S = DATE THEN TeacherNote
				ELSE ''
			END AS TeacherNote, MET_TIME,
			(
				SELECT COUNT(DISTINCT TeacherName)
				FROM #claim
			) As TeacherCount
		FROM
			#days
			INNER JOIN
				(
					SELECT
						dbo.DateOf(MEETING_DATE) AS MET_DATE_S, TeacherName,
						LEFT(CONVERT(VARCHAR(20), MEETING_DATE, 108), 5) AS MET_TIME,
						CONVERT(VARCHAR(20), STATUS) + ClientName + CHAR(10) + ISNULL(MEETING_NOTE + CHAR(10), CHAR(10)) AS TeacherNote
					FROM #claim t
				) AS o_O ON MET_DATE_S = DATE
		ORDER BY DATE, MET_TIME

		IF OBJECT_ID('tempdb..#claim') IS NOT NULL
			DROP TABLE #claim

		IF OBJECT_ID('tempdb..#days') IS NOT NULL
			DROP TABLE #days

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_STUDY_CLAIM_MEETING_REPORT_PRINT_2] TO rl_client_study_claim_meeting;
GO