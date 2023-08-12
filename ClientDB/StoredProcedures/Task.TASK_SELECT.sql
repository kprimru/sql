USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Task].[TASK_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Task].[TASK_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Task].[TASK_SELECT]
	@USER		NVARCHAR(128),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SHORT		BIT,
	@CLIENT		BIT,
	@PERSONAL	BIT,
	@STATUS		NVARCHAR(MAX)
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

		IF @USER IS NULL OR (IS_MEMBER('rl_task_all') = 0 AND IS_MEMBER('db_owner') = 0)
			SET @USER = ORIGINAL_LOGIN()

		IF @STATUS IS NULL
			SET @STATUS =
				(
					SELECT ID AS ITEM
					FROM Task.TaskStatus
					FOR XML PATH(''), ROOT('LIST')
				)

		IF OBJECT_ID('tempdb..#task') IS NOT NULL
			DROP TABLE #task

		CREATE TABLE #task
			(
				ID			UNIQUEIDENTIFIER,
				DATE		SMALLDATETIME,
				WD			INT,
				TM			VARCHAR(20),
				HR			INT,
				SHORT		NVARCHAR(MAX),
				RN			INT,
				ID_STATUS	TINYINT,
				REC_TP		INT
			)

		INSERT INTO #task(ID, DATE, WD, TM, HR, SHORT, RN, ID_STATUS, REC_TP)
		SELECT
			ID, DATE, WD, TM, HOUR_INT, SHORT,
			ROW_NUMBER() OVER(PARTITION BY WD, HOUR_INT ORDER BY DATE, TM),
			INT_VAL, REC_TP
		FROM
			(
				SELECT
					a.ID, DATE, DATEPART(WEEKDAY, DATE) AS WD, LEFT(CONVERT(VARCHAR(20), TIME, 108), 5) AS TM,
					CASE
						WHEN DATEPART(HOUR, TIME) > 20 THEN NULL
						WHEN DATEPART(HOUR, TIME) < 8 THEN NULL
						ELSE DATEPART(HOUR, TIME)
					END AS HOUR_INT,
					ISNULL('до ' + CONVERT(VARCHAR(20), EXPIRE, 104) + CHAR(10), '') +
					ISNULL(ClientFullName + CHAR(10), '') +
					CASE
						WHEN @SHORT = 1 THEN SHORT
						ELSE SHORT + CHAR(10) + NOTE
					END + CHAR(10) + '/' + SENDER + '/' AS SHORT, 
					INT_VAL, 1 AS REC_TP
				FROM
					Task.Tasks a
					INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
					INNER JOIN dbo.TableGUIDFromXML(@STATUS) d ON d.ID = b.ID
					LEFT OUTER JOIN dbo.ClientTable c ON c.ClientID = ID_CLIENT
				WHERE a.STATUS = 1
					AND DATE BETWEEN @BEGIN AND @END
					AND
						(
							-- личные
							@PERSONAL = 1
							AND
								(
									RECEIVER = @USER
									OR
									RECEIVER IN
										(
											SELECT ServiceLogin
											FROM
												dbo.ServiceTable z
												INNER JOIN dbo.ManagerTable y ON z.ManagerID = y.ManagerID
											WHERE ManagerLogin = @USER
										)
								)

							OR 

							@CLIENT = 1
							AND ID_CLIENT IN
								(
									SELECT ClientID
									FROM dbo.ClientView WITH(NOEXPAND)
									WHERE ServiceLogin = @USER
										OR ManagerLogin = @USER
								)
						)

				UNION ALL

				SELECT
					a.ID, dbo.DateOf(a.DATE), DATEPART(WEEKDAY, a.DATE) AS WD, LEFT(CONVERT(VARCHAR(20), DATE, 108), 5) TM,
					CASE
						WHEN DATEPART(HOUR, DATE) > 20 THEN NULL
						WHEN DATEPART(HOUR, DATE) < 8 THEN NULL
						ELSE DATEPART(HOUR, DATE)
					END AS HOUR_INT, 
					'Контакт' + CHAR(10) + ISNULL(ClientFullName + CHAR(10), '') +
					a.NOTE  + CHAR(10) + a.UPD_USER,

					NULL, 2
				FROM
					dbo.ClientContact a
					INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.ClientID
				WHERE a.STATUS = 1
					AND a.DATE BETWEEN @BEGIN AND @END
					AND
						(
							ID_CLIENT IN
							(
								SELECT ClientID
								FROM dbo.ClientView WITH(NOEXPAND)
								WHERE ServiceLogin = @USER
									OR ManagerLogin = @USER
							)

							OR

							a.UPD_USER = @USER
						)
		) AS o_O


		UPDATE #task
		SET HR = NULL
		WHERE HR < 8 OR HR > 20

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				START	INT,
				FINISH	INT,
				TXT		VARCHAR(20),
				RN		INT
			)

		INSERT INTO #result(START, FINISH, TXT, RN)
			SELECT START, FINISH, TXT, ISNULL(RN, 1)
			FROM
				(
					SELECT 8 AS START, 9 AS FINISH, '8:00 - 9:00' AS TXT
					UNION ALL
					SELECT 9 AS START, 10 AS FINISH, '9:00 - 10:00' AS TXT
					UNION ALL
					SELECT 10 AS START, 11 AS FINISH, '10:00 - 11:00' AS TXT
					UNION ALL
					SELECT 11 AS START, 12 AS FINISH, '11:00 - 12:00' AS TXT
					UNION ALL
					SELECT 12 AS START, 13 AS FINISH, '12:00 - 13:00' AS TXT
					UNION ALL
					SELECT 13 AS START, 14 AS FINISH, '13:00 - 14:00' AS TXT
					UNION ALL
					SELECT 14 AS START, 15 AS FINISH, '14:00 - 15:00' AS TXT
					UNION ALL
					SELECT 15 AS START, 16 AS FINISH, '15:00 - 16:00' AS TXT
					UNION ALL
					SELECT 16 AS START, 17 AS FINISH, '16:00 - 17:00' AS TXT
					UNION ALL
					SELECT 17 AS START, 18 AS FINISH, '17:00 - 18:00' AS TXT
					UNION ALL
					SELECT 18 AS START, 19 AS FINISH, '18:00 - 19:00' AS TXT
					UNION ALL
					SELECT 19 AS START, 20 AS FINISH, '19:00 - 20:00' AS TXT
					UNION ALL
					SELECT 20 AS START, 21 AS FINISH, '20:00 - 21:00' AS TXT
					UNION ALL
					SELECT NULL AS START, NULL AS FINISH, '-' AS TXT
				) AS a
				LEFT OUTER JOIN
				(
					SELECT DISTINCT HR, RN
					FROM #task z
					WHERE EXISTS
						(
							SELECT *
							FROM #task y
							WHERE (z.HR = y.HR OR z.HR IS NULL AND y.HR IS NULL) AND y.RN > 1
						)
				) AS b ON a.START = b.HR OR a.START IS NULL AND b.HR IS NULL

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'ALTER TABLE #result ADD '
		SELECT @SQL = @SQL +
			'DAY_' + CONVERT(VARCHAR(20), RN) + ' NVARCHAR(MAX), ID_' + CONVERT(VARCHAR(20), RN) + ' UNIQUEIDENTIFIER, STAT_' + CONVERT(VARCHAR(20), RN) + ' TINYINT, TP_' + CONVERT(VARCHAR(20), RN) + ' TINYINT,'
		FROM
			(
				SELECT CONVERT(VARCHAR(20), DATEPART(DAY, CalendarDate)) + ' ' + dbo.MonthString(CalendarDate) AS CAPT, ROW_NUMBER() OVER(ORDER BY CalendarDate) AS RN
				FROM dbo.Calendar
				WHERE CalendarDate BETWEEN @BEGIN AND @END
			) AS o_O

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		SET @SQL = N'
		UPDATE a
		SET '

		SELECT @SQL = @SQL + N'
			DAY_' + CONVERT(VARCHAR(20), RN) + ' =
			(
				SELECT SHORT
				FROM #task b
				WHERE (a.START IS NULL AND b.HR IS NULL OR a.START = b.HR)
					AND a.RN = b.RN AND b.DATE = DATEADD(DAY, ' + CONVERT(VARCHAR(20), RN - 1) + ', ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''')
			),
			STAT_' + CONVERT(VARCHAR(20), RN) + ' =
			(
				SELECT ID_STATUS
				FROM #task b
				WHERE (a.START IS NULL AND b.HR IS NULL OR a.START = b.HR)
					AND a.RN = b.RN AND b.DATE = DATEADD(DAY, ' + CONVERT(VARCHAR(20), RN - 1) + ', ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''')
			),
			ID_' + CONVERT(VARCHAR(20), RN) + ' =
			(
				SELECT ID
				FROM #task b
				WHERE (a.START IS NULL AND b.HR IS NULL OR a.START = b.HR)
					AND a.RN = b.RN AND b.DATE = DATEADD(DAY, ' + CONVERT(VARCHAR(20), RN - 1) + ', ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''')
			),
			TP_' + CONVERT(VARCHAR(20), RN) + ' =
			(
				SELECT REC_TP
				FROM #task b
				WHERE (a.START IS NULL AND b.HR IS NULL OR a.START = b.HR)
					AND a.RN = b.RN AND b.DATE = DATEADD(DAY, ' + CONVERT(VARCHAR(20), RN - 1) + ', ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''')
			),'
		FROM
			(
				SELECT CONVERT(VARCHAR(20), DATEPART(DAY, CalendarDate)) + ' ' + dbo.MonthString(CalendarDate) AS CAPT, ROW_NUMBER() OVER(ORDER BY CalendarDate) AS RN
				FROM dbo.Calendar
				WHERE CalendarDate BETWEEN @BEGIN AND @END
			) AS o_O

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		SET @SQL = @SQL + N'
		FROM #result a'

		EXEC  (@SQL)

		SELECT *
		FROM #result
		ORDER BY START

		IF OBJECT_ID('tempdb..#task') IS NOT NULL
			DROP TABLE #task

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
GRANT EXECUTE ON [Task].[TASK_SELECT] TO rl_task_r;
GO
