USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_RIVAL_REPORT]
	@CL_ID INT,
	@STATUS UNIQUEIDENTIFIER,	
	@STUDY	INT,
	@RIVAL	INT,
	@EVENT_DATE	SMALLDATETIME,
	@EVENT_COUNT INT,
	@MANAGER VARCHAR(100) = NULL OUTPUT, 
	@SERVICE VARCHAR(100) = NULL OUTPUT,
	@SYSTEMS VARCHAR(500) = NULL OUTPUT	
AS
BEGIN
	SET NOCOUNT ON;
	
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
	FROM 
		dbo.ClientDistrView a
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
			EventDate SMALLDATETIME NULL,
			EventText VARCHAR(MAX) NULL,
			StudyDateTeacher VARCHAR(150) NULL,		
			StudyComment VARCHAR(MAX),
			RivalDateType VARCHAR(150),
			RivalCondition VARCHAR(MAX),
			RivalAction VARCHAR(MAX)
		)
		
	DECLARE @EVENT TABLE (ID INT IDENTITY(1, 1), DATE SMALLDATETIME, TXT VARCHAR(MAX))

	INSERT INTO @EVENT (DATE, TXT)
		SELECT EventDate, REPLACE(EventComment, CHAR(10), '')
		FROM dbo.EventTable
		WHERE ClientID = @CL_ID
			AND EventActive = 1
			AND (EventDate >= @EVENT_DATE OR @EVENT_DATE IS NULL)
		ORDER BY EventDate DESC, EventID DESC

	IF @EVENT_COUNT IS NOT NULL
		DELETE FROM @EVENT WHERE ID > @EVENT_COUNT

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
		ORDER BY DATE DESC, ID DESC	

	DELETE FROM @STD WHERE ID > @STUDY

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
	
	

	DELETE FROM @RIV WHERE ID > @RIVAL

	DECLARE @MAX INT
	SET @MAX = 0

	SELECT @MAX = COUNT(*)
	FROM @EVENT

	IF (SELECT COUNT(*) FROM @STD) > @MAX
		SELECT @MAX = COUNT(*)
		FROM @STD

	IF (SELECT COUNT(*) FROM @RIV) > @MAX
		SELECT @MAX = COUNT(*)
		FROM @RIV

	DECLARE @i INT

	SET @i = 0
	WHILE @I < @MAX
	BEGIN
		INSERT INTO @result DEFAULT VALUES
		
		SET @I = @I + 1
	END

	UPDATE t
	SET EventDate = DATE,
		EventText = TXT
	FROM 
		@RESULT t 
		INNER JOIN @EVENT e ON e.ID = t.NUM
	
	UPDATE t
	SET t.StudyDateTeacher = e.DateTeacher,
		t.StudyComment = e.StudyComment
	FROM 
		@RESULT t 
		INNER JOIN @STD e ON e.ID = t.NUM

	UPDATE t
	SET t.RivalDateType = e.DateType,
		t.RivalCondition = e.Condition,
		t.RivalAction = e.Action
	FROM 
		@RESULT t 
		INNER JOIN @RIV e ON e.ID = t.NUM

	SELECT *
	FROM @RESULT
	ORDER BY NUM
END