USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[FILTER_STUDY_DATA]
	@LESSON_PLACE	INT,
	@BEGIN			SMALLDATETIME,
	@END			SMALLDATETIME,
	@COMMENT		VARCHAR(100),
	@CLIENT			VARCHAR(100),
	@STUDENT		VARCHAR(100),
	@MANAGER		INT,
	@SERVICE		INT,
	@TEACHER		NVARCHAR(MAX),
	@STATUS			INT,
	@SEMINAR		BIT = NULL,
	@STUDY			SMALLINT = 0,
	@TYPE			UNIQUEIDENTIFIER = NULL,
	@CL_CNT			INT = NULL OUTPUT,
	@SERTIFICAT		BIT = NULL
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

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		SELECT
			ROW_NUMBER() OVER(ORDER BY b.DATE DESC, ClientFullName, SURNAME) AS RN,
			a.ClientID, ClientFullName, b.DATE AS StudyDate,
			TeacherName, ServiceName, b.NOTE AS StudyNote,
			(SURNAME + ' ' + d.NAME + ' ' + PATRON) AS Student,
			POSITION AS StudentPositionName, CASE ClientMainBook WHEN 0 THEN 'Нет' ELSE 'Да' END AS CL_MAINBOOK,
			b.TEACHED, t.NAME AS TP_NAME
		INTO #result
		FROM
			dbo.ClientTable a
			INNER JOIN dbo.ClientStudy b ON a.ClientID = b.ID_CLIENT
			INNER JOIN dbo.TeacherTable c ON c.TeacherID = b.ID_TEACHER
			INNER JOIN dbo.ServiceTable y ON ServiceID = ClientServiceID
			INNER JOIN dbo.ManagerTable z ON y.ManagerID = z.ManagerID
			LEFT OUTER JOIN dbo.ClientStudyPeople d ON d.ID_STUDY = b.ID
			LEFT OUTER JOIN dbo.StudyType t ON t.ID = b.ID_TYPE
		WHERE (ID_PLACE = @LESSON_PLACE OR @LESSON_PLACE IS NULL)
			AND a.STATUS = 1
			AND b.STATUS = 1
			AND (@STUDY = 0 OR @STUDY = 1 AND b.TEACHED = 1 OR @STUDY = 2 AND b.TEACHED = 0)
			AND (b.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (b.DATE <= @END OR @END IS NULL)
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND ((SURNAME + ' ' + d.NAME + ' ' + PATRON) LIKE @STUDENT OR @STUDENT IS NULL)
			AND (z.ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (b.ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
			AND (b.NOTE LIKE @COMMENT OR @COMMENT IS NULL)
			AND (StatusID = @STATUS OR @STATUS IS NULL)
			AND (b.ID_TYPE = @TYPE OR @TYPE IS NULL)
			AND (@SERTIFICAT IS NULL OR @SERTIFICAT = 0 OR @SERTIFICAT = 1 AND d.ID_SERT_TYPE IS NOT NULL)
			AND (
					EXISTS
						(
							SELECT *
							FROM
								dbo.ClientStudy z INNER JOIN
								dbo.ClientStudyPeople y ON z.ID = y.ID_STUDY INNER JOIN
								dbo.LessonPlaceTable x ON x.LessonPlaceID = z.ID_PLACE
							WHERE z.ID_CLIENT = a.ClientID
								AND z.DATE >= b.DATE
								AND y.SURNAME = d.SURNAME
								AND x.LessonPlaceReport <> 1
						)
					OR @SEMINAR = 0
				)

		ORDER BY b.DATE DESC, ClientFullName, SURNAME

		SELECT @CL_CNT = COUNT(DISTINCT ClientID)
		FROM #result

		SELECT *
		FROM #result
		ORDER BY StudyDate DESC, ClientFullName, Student

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
GRANT EXECUTE ON [dbo].[FILTER_STUDY_DATA] TO rl_filter_study;
GO