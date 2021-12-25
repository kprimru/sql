USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TEACHER_MONTH_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TEACHER_MONTH_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TEACHER_MONTH_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TEACHER	NVARCHAR(MAX),
	@TP			TINYINT, /*0 - количество занятий, 1 - колиечство клиентов, 2 - количество пользователей*/
	@TYPE		NVARCHAR(MAX) -- тип клиента
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

		DECLARE @MONDAY INT

		SELECT @MONDAY = DayID FROM dbo.DayTable WHERE DayOrder = 1

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				TEACHER		INT,
				PERIOD		UNIQUEIDENTIFIER,
				CL_COUNT	INT,
				LESSON		INT,
				PEOPLE		INT
			)

		INSERT INTO #result(TEACHER, PERIOD, CL_COUNT, LESSON, PEOPLE)
			SELECT
				TeacherID, ID,
				(
					SELECT COUNT(DISTINCT ID_CLIENT)
					FROM
						dbo.ClientStudy z
						INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
						INNER JOIN dbo.TableIDFromXML(@TYPE) y ON y.ID = ClientKind_Id
					WHERE z.STATUS = 1
						AND TEACHED = 1
						AND ID_TEACHER = TeacherID
						AND DATE >= START AND DATE <= FINISH
				) AS CL_COUNT,
				(
					SELECT COUNT(*)
					FROM
						dbo.ClientStudy z
						INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
						INNER JOIN dbo.TableIDFromXML(@TYPE) y ON y.ID = ClientKind_Id
					WHERE z.STATUS = 1
						AND TEACHED = 1
						AND ID_TEACHER = TeacherID
						AND DATE >= START AND DATE <= FINISH
				) AS LESSON,
				(
					SELECT SUM(CASE WHEN GR_COUNT IS NULL THEN 1 ELSE GR_COUNT END)
					FROM
						dbo.ClientStudy z
						INNER JOIN dbo.ClientStudyPeople y ON z.ID = y.ID_STUDY
						INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
						INNER JOIN dbo.TableIDFromXML(@TYPE) x ON x.ID = ClientKind_Id
					WHERE z.STATUS = 1
						AND TEACHED = 1
						AND ID_TEACHER = TeacherID
						AND DATE >= START AND DATE <= FINISH
				) As PEOPLE
			FROM
				(
					SELECT TeacherID, TeacherName
					FROM
						dbo.TeacherTable
						INNER JOIN dbo.TableIDFromXML(@TEACHER) ON ID = TeacherID
				) AS Teach
				CROSS JOIN
				(
					SELECT ID, START, FINISH
					FROM Common.Period
					WHERE TYPE = 2
						AND START >= @BEGIN
						AND START <= @END
				) AS Pr

		SELECT
			NAME, TeacherName, VAL, DAY_CNT, DAY_CNT * TeacherNorma AS NORMA, ROUND(100 * CONVERT(FLOAT, VAL) / NULLIF((DAY_CNT * TeacherNorma), 0), 2) AS PRC,
			'Дней в месяце: ' + CONVERT(VARCHAR(20), DAY_CNT) + CHAR(10) +
			'Норма: ' + CONVERT(VARCHAR(20), DAY_CNT * TeacherNorma) + CHAR(10) +
			'Итого занятий: ' + CONVERT(VARCHAR(20), VAL) AS DATA
			--'Норма выполнена на ' + CONVERT(VARCHAR(20), ROUND(100 * CONVERT(FLOAT, VAL) / (DAY_CNT * TeacherNorma), 2)) + ' %' ,
			--CASE WHEN ROUND(100 * CONVERT(FLOAT, VAL) / (DAY_CNT * TeacherNorma), 2) >= 100 THEN 1 ELSE 0 END AS NORMA_COMPLETE
		FROM
			(
				SELECT
					START, NAME, TeacherName, ISNULL(TeacherNorma, 0) AS TeacherNorma,
					/*CASE @TP*/ /*0 - количество занятий, 1 - колиечство клиентов, 2 - количество пользователей*/
						/*WHEN 0 THEN LESSON
						WHEN 1 THEN CL_COUNT
						WHEN 2 THEN PEOPLE
						ELSE*/ LESSON
					/*END*/ AS VAL,
					/*
					считаем количество рабочих дней между датами исключая понедельники
					*/
					(
						SELECT COUNT(*)
						FROM dbo.Calendar
						WHERE CalendarDate >= a.START
							AND CalendarDate <= a.FINISH
							AND CalendarWork = 1
							--AND CalendarWeekDayID <> @MONDAY
					) -
					(
						SELECT COUNT(DISTINCT y.ID)
						FROM
							dbo.Calendar z
							INNER JOIN Common.Period y ON y.START <= z.CalendarDate AND y.FINISH >= z.CalendarDate
						WHERE CalendarDate >= a.START
							AND CalendarDate <= a.FINISH
							AND CalendarWork = 1
							--AND CalendarWeekDayID <> @MONDAY
							AND y.TYPE = 1
					) AS DAY_CNT
					--,CL_COUNT, LESSON, PEOPLE
				FROM
					#result
					INNER JOIN dbo.TeacherTable ON TEACHER = TeacherID
					INNER JOIN Common.Period a ON ID = PERIOD
			) AS o_O
		ORDER BY START, TeacherName

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
GRANT EXECUTE ON [dbo].[TEACHER_MONTH_REPORT] TO rl_teacher_month_report;
GO
