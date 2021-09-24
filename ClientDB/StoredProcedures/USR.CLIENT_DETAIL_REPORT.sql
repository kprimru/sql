USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[CLIENT_DETAIL_REPORT]
	@CL_ID		INT,
	@SEARCH		SMALLDATETIME,
	@STATUS		UNIQUEIDENTIFIER,
	@UPDATE		INT,
	@STUDY		INT,
	@RIVAL		INT,
	@MANAGER	VARCHAR(100) = NULL OUTPUT,
	@SERVICE	VARCHAR(100) = NULL OUTPUT,
	@SYSTEMS	VARCHAR(500) = NULL OUTPUT
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

		DECLARE @DISCONNECT SMALLDATETIME

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDistrView a WITH(NOEXPAND)
				WHERE ID_CLIENT = @CL_ID
					AND DS_REG = 0
			)
			SELECT @DISCONNECT = MAX(DisconnectDate)
			FROM dbo.ClientDisconnectView WITH(NOEXPAND)
			WHERE ClientID = @CL_ID

		SELECT TOP 1 @MANAGER = MANAGER, @SERVICE = ServiceName
		FROM
			dbo.ClientService
			INNER JOIN dbo.ServiceTable ON ServiceID = ID_SERVICE
		WHERE DATE <= @DISCONNECT
			AND ID_CLIENT = @CL_ID
		ORDER BY DATE DESC

		IF @DISCONNECT IS NULL OR @SERVICE IS NULL OR @MANAGER IS NULL
			SELECT @MANAGER = ManagerName, @SERVICE = ServiceName
			FROM dbo.ClientView a WITH(NOEXPAND)
			WHERE ClientID = @CL_ID

		SET @SYSTEMS = ''

		SELECT @SYSTEMS = @SYSTEMS + SystemShortName + ', '
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		WHERE ID_CLIENT = @CL_ID
			AND (DS_ID = @STATUS OR @STATUS IS NULL)

		IF LEN(@SYSTEMS) > 0
		BEGIN
			SET @SYSTEMS = RTRIM(@SYSTEMS)
			SET @SYSTEMS = LEFT(@SYSTEMS, LEN(@SYSTEMS) - 1)
		END

		DECLARE @ST VARCHAR(50)

		SELECT @ST = ServiceTypeShortName
		FROM
			dbo.ClientTable a INNER JOIN
			dbo.ServiceTypeTable b ON a.ServiceTypeID = b.ServiceTypeID
		WHERE ClientID = @CL_ID

		IF @ST IS NOT NULL
			SET @SYSTEMS = '(сопр - ' + @ST + ') ' + @SYSTEMS

		SET @SYSTEMS = @SYSTEMS + ISNULL('(' + CONVERT(NVARCHAR(32), (SELECT MIN(ConnectDate) FROM dbo.ClientConnectView WITH(NOEXPAND) WHERE ClientID = @CL_ID), 104) + ')', '')

		DECLARE @RESULT TABLE
			(
				NUM INT IDENTITY(1, 1) PRIMARY KEY,
				UpdDate SMALLDATETIME NULL,
				EventDate SMALLDATETIME NULL,
				EventText VARCHAR(MAX) NULL,
				StudyDateTeacher VARCHAR(150) NULL,
				StudyComment VARCHAR(MAX),
				TechDate SMALLDATETIME NULL,
				TechProblem VARCHAR(MAX),
				TechResult	VARCHAR(MAX),
				DutyDate SMALLDATETIME NULL,
				DutyType VARCHAR(100) NULL,
				DutySystem VARCHAR(MAX) NULL,
				SearchDate VARCHAR(100) NULL,
				SearchCount INT NULL
			)

		DECLARE @TUPD TABLE
			(
				DATE SMALLDATETIME PRIMARY KEY,
				NUM INT IDENTITY(1, 1)
			)

		INSERT INTO @TUPD (DATE)
			SELECT DISTINCT UIU_DATE_S
			FROM USR.USRIBDateView WITH(NOEXPAND)
			WHERE UD_ID_CLIENT = @CL_ID
			ORDER BY UIU_DATE_S DESC

		DELETE FROM @TUPD WHERE NUM > @UPDATE

		DECLARE @B_UPD SMALLDATETIME
		DECLARE @E_UPD SMALLDATETIME

		SELECT @B_UPD = MIN(DATE), @E_UPD = MAX(DATE)
		FROM @TUPD

		DECLARE @T_DATE SMALLDATETIME

		SELECT @T_DATE = MAX(EventDate)
		FROM dbo.EventTable
		WHERE ClientID = @CL_ID
			AND EventActive = 1
			AND EventDate > @B_UPD

		IF @T_DATE > @E_UPD
			SET @E_UPD = @T_DATE

		DECLARE @EVENT TABLE (DATE SMALLDATETIME, TXT VARCHAR(MAX))

		INSERT INTO @EVENT (DATE, TXT)
			SELECT EventDate, REPLACE(EventComment, CHAR(10), '')
			FROM dbo.EventTable
			WHERE ClientID = @CL_ID
				AND EventActive = 1
				AND EventDate BETWEEN DATEADD(MONTH, -1, @B_UPD) AND @E_UPD

		IF NOT EXISTS(SELECT * FROM @EVENT)
			INSERT INTO @EVENT (DATE, TXT)
				SELECT TOP 5 EventDate, REPLACE(EventComment, CHAR(10), '')
				FROM dbo.EventTable
				WHERE ClientID = @CL_ID
					AND EventActive = 1
				ORDER BY EventDate DESC


		DECLARE @DUTY TABLE (NUM INT IDENTITY(1, 1), DATE SMALLDATETIME, DTYPE VARCHAR(100), DSYSTEM VARCHAR(500))

		INSERT INTO @DUTY(DATE, DTYPE, DSYSTEM)
			SELECT
				dbo.DateOf(ClientDutyDateTime), ISNULL(CallTypeShort, CallTypeName) AS CallTypeName,
				REVERSE(
					STUFF(
						REVERSE(
							(
								SELECT SystemShortName + ','
								FROM
									(
										SELECT DISTINCT SystemShortName, SystemOrder
										FROM
											dbo.ClientDutyIBTable b INNER JOIN
											dbo.SystemTable d ON d.SystemID = b.SystemID
										WHERE a.ClientDutyID = b.ClientDutyID
									) AS dt
								ORDER BY SystemOrder FOR XML PATH('')
							)
							 ), 1, 1, ''))
			FROM
				dbo.ClientDutyTable a INNER JOIN
				dbo.CallTypeTable c ON a.CallTypeID = c.CallTypeID
			WHERE a.ClientID = @CL_ID AND STATUS = 1

		DECLARE @TSRCH TABLE(NUM INT IDENTITY(1, 1), DATE VARCHAR(50), CNT INT)

		INSERT INTO @TSRCH(DATE, CNT)
			SELECT
				SearchMonth,
				(
					SELECT  COUNT(*)
					FROM dbo.ClientSearchTable a
					WHERE a.SearchMonth = dt.SearchMonth
						AND a.ClientID = @CL_ID
				)
			FROM
				(
					SELECT DISTINCT SearchMonth, SearchMonthDate
					FROM dbo.ClientSearchTable
					WHERE ClientID = @CL_ID
						AND SearchDate >= @SEARCH
				) AS dt
			ORDER BY SearchMonthDate

		INSERT INTO @RESULT
			(
				UpdDate, EventDate, EventText
			)
			SELECT
				c.DATE, b.DATE, b.TXT
			FROM
				(
					SELECT DATE AS CDATE
					FROM @TUPD

					UNION

					SELECT DATE
					FROM @EVENT
				) a LEFT OUTER JOIN
				@EVENT b ON a.CDATE = b.DATE LEFT OUTER JOIN
				@TUPD c ON c.DATE = a.CDATE

		DECLARE @STD	TABLE
			(
				ID	INT	IDENTITY(1, 1) PRIMARY KEY,
				DateTeacher	VARCHAR(150),
				StudyComment	VARCHAR(MAX)
			)

		INSERT INTO @STD(DateTeacher, StudyComment)
			SELECT
				CONVERT(VARCHAR(20), DATE, 104) + ' ' + TeacherName,
				CASE REPLACE(RECOMEND, CHAR(10), '')
					WHEN '' THEN ''
					ELSE REPLACE(RECOMEND, CHAR(10), '') + CHAR(10)
				END +
				REPLACE(NOTE, CHAR(10), '')
			FROM
				dbo.ClientStudy a INNER JOIN
				dbo.TeacherTable b ON a.ID_TEACHER = b.TeacherID
			WHERE ID_CLIENT = @CL_ID AND STATUS = 1
			ORDER BY DATE DESC, a.ID DESC

		DECLARE @STUDY_COUNT	INT

		SELECT @STUDY_COUNT = COUNT(*)
		FROM @STD

		IF @STUDY_COUNT > @STUDY
			SET @STUDY_COUNT = @STUDY

		IF ISNULL((SELECT MAX(NUM) FROM @RESULT), 0) < @STUDY
			INSERT INTO @RESULT(StudyDateTeacher, StudyComment)
				SELECT DateTeacher, StudyComment
				FROM @STD
				WHERE ID > ISNULL((SELECT MAX(NUM) FROM @RESULT), 0)
					AND ID <= @STUDY

		UPDATE t
		SET t.StudyDateTeacher = p.DateTeacher,
			t.StudyComment = p.StudyComment
		FROM
			@RESULT t INNER JOIN
			@STD p ON t.NUM = p.ID
		WHERE ID <= @STUDY

		DECLARE @RIV	TABLE
			(
				ID	INT	IDENTITY(1, 1) PRIMARY KEY,
				DateType	VARCHAR(150),
				Condition	VARCHAR(MAX),
				Action		VARCHAR(MAX)
			)

		INSERT INTO @RIV(DateType, Condition, Action)
			SELECT
				CONVERT(VARCHAR(20), CR_DATE, 104) + ' ' + ISNULL(RivalTypeName, ''),
				REPLACE(CR_CONDITION, CHAR(10), ''),
				REVERSE(
					STUFF(
						REVERSE(
							(
								SELECT CONVERT(VARCHAR(20), CRR_DATE, 104) + ' ' + REPLACE(CRR_COMMENT, CHAR(10), '') + CHAR(10) + ','
								FROM dbo.ClientRivalReaction
								WHERE CRR_ID_RIVAL = CR_ID
									AND CRR_ACTIVE = 1
								ORDER BY CRR_DATE DESC, CRR_ID DESC FOR XML PATH('')
							)
						), 1, 1, ''
					)
				)
			FROM
				dbo.ClientRival a
				LEFT OUTER JOIN dbo.RivalTypeTable b ON a.CR_ID_TYPE = b.RivalTypeID
			WHERE CL_ID = @CL_ID AND CR_ACTIVE = 1
			ORDER BY CR_DATE DESC, CR_ID DESC


		IF ISNULL((SELECT MAX(NUM) FROM @RESULT), 0) < @RIVAL + @STUDY_COUNT
			INSERT INTO @RESULT(StudyDateTeacher, StudyComment)
				SELECT DateType, Condition + CHAR(10) + Action
				FROM @RIV
				WHERE ID > ISNULL((SELECT MAX(NUM) FROM @RESULT), 0)
					AND ID <= @RIVAL

		UPDATE t
		SET t.StudyDateTeacher = p.DateType,
			t.StudyComment = p.Condition + CHAR(10) + Action
		FROM
			@RESULT t INNER JOIN
			@RIV p ON t.NUM - @STUDY_COUNT = p.ID
		WHERE ID <= @RIVAL


		DECLARE @TECH TABLE
			(
				ID	INT IDENTITY(1, 1) PRIMARY KEY,
				DT	SMALLDATETIME,
				PROB VARCHAR(MAX),
				RES	VARCHAR(MAX)
			)

		INSERT INTO @TECH(DT, PROB, RES)
			SELECT
				CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), CLM_DATE, 112), 112), CLM_PROBLEM,
				CONVERT(VARCHAR(20), CLM_EX_DATE, 104) + ' ' +
				CLM_EXECUTOR + ' ' +
				CLM_EXECUTE_ACTION
			FROM dbo.ClaimTable
			WHERE CLM_ID_CLIENT = @CL_ID

		UPDATE t
		SET t.TechDate = p.DT,
			t.TechProblem = p.PROB,
			t.TechResult = p.RES
		FROM
			@RESULT t INNER JOIN
			@TECH p ON t.NUM = p.ID

		UPDATE r
		SET
			DutyDate = DATE,
			DutyType = DTYPE,
			DutySystem = DSYSTEM
		FROM
			@RESULT r INNER JOIN
			@DUTY d ON d.NUM = r.NUM

		INSERT INTO @RESULT(DutyDate, DutyType, DutySystem)
			SELECT DATE, DTYPE, DSYSTEM
			FROM @DUTY a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM @RESULT b
					WHERE a.NUM = b.NUM
				)

		UPDATE r
		SET
			SearchDate = DATE,
			SearchCount = CNT
		FROM
			@RESULT r INNER JOIN
			@TSRCH d ON d.NUM = r.NUM

		INSERT INTO @RESULT(SearchDate, SearchCount)
			SELECT DATE, CNT
			FROM @TSRCH a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM @RESULT b
					WHERE a.NUM = b.NUM
				)

		SELECT *
		FROM @RESULT
		ORDER BY NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[CLIENT_DETAIL_REPORT] TO rl_client_detail_report;
GO
