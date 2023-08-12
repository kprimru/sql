USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_STUDY_CLAIM_MEETING_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_STUDY_CLAIM_MEETING_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_STUDY_CLAIM_MEETING_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
WITH EXECUTE AS OWNER
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
				ClientName		VARCHAR(500)
			)

		INSERT INTO #claim(TeacherName, MEETING_DATE, MEETING_NOTE, ClientName)
			SELECT TeacherName, MEETING_DATE, MEETING_NOTE, ClientFullName + ' (' + CA_STR + ')'
			FROM
				(
					SELECT MEETING_DATE, TeacherName, MEETING_NOTE, ClientFullName, CA_STR
					FROM
						dbo.ClientStudyClaim a
						INNER JOIN dbo.TeacherTable ON TeacherID = ID_TEACHER
						INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
						INNER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ID_CLIENT
					WHERE a.STATUS IN (1, 5)

					UNION ALL

					SELECT b.DATE, TeacherName, b.NOTE, ClientFullName, CA_STR
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

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				DATE		SMALLDATETIME,
				DATE_NOTE	NVARCHAR(256)
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'ALTER TABLE #result ADD ' +
			REVERSE(STUFF(REVERSE(
				(
					SELECT '[' + TeacherName + '] NVARCHAR(MAX), '
					FROM
						(
							SELECT DISTINCT TeacherName
							FROM #claim
						) AS o_O
					ORDER BY TeacherName FOR XML PATH('')
				)), 1, 2, ''))

		EXEC (@SQL)

		INSERT INTO #result(DATE, DATE_NOTE)
			SELECT DATE, CONVERT(VARCHAR(20), DATE, 104) + ' (' + NAME + ')'
			FROM #days

		SET @SQL = ''

		SELECT @SQL = @SQL + N'
		[' + TeacherName + '] =
			REVERSE(STUFF(REVERSE(
				(
					SELECT LEFT(CONVERT(VARCHAR(20), MEETING_DATE, 108), 5) + '' '' + ClientName + CHAR(10) + ISNULL(MEETING_NOTE + CHAR(10), CHAR(10)) + CHAR(10)
					FROM #claim z
					WHERE z.TeacherName = ''' + TeacherName + ''' AND dbo.DateOf(DATE) = dbo.DateOf(MEETING_DATE)
					ORDER BY MEETING_DATE FOR XML PATH('''')
				)), 1, 1, '''')),'
			FROM (SELECT DISTINCT TeacherName FROM #claim) AS o_O

		IF @SQL <> ''
		BEGIN
			SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

			SET @SQL = N'
			UPDATE #result
			SET ' + @SQL

			EXEC (@SQL)
		END

		SELECT *
		FROM #result

		/*
		SELECT TeacherName, dbo.DateOf(MEETING_DATE) AS MEETING_DATE_S, MEETING_DATE, MEETING_NOTE
		FROM #claim
		ORDER BY MEETING_DATE, TeacherName
		*/

		IF OBJECT_ID('tempdb..#claim') IS NOT NULL
			DROP TABLE #claim

		IF OBJECT_ID('tempdb..#days') IS NOT NULL
			DROP TABLE #days

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STUDY_CLAIM_MEETING_REPORT] TO rl_client_study_claim_meeting;
GO
