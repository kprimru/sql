USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@CLAIM		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@PLACE		INT,
	@TEACHER	INT,
	@NEED		NVARCHAR(MAX),
	@RECOMEND	NVARCHAR(MAX),
	@NOTE		NVARCHAR(MAX),
	@TEACHED	BIT,
	@PEOPLE		NVARCHAR(MAX),
	@REPEAT		SMALLDATETIME,
	@SYSTEMS	NVARCHAR(MAX) = NULL,
	@ID_TYPE	UNIQUEIDENTIFIER = NULL,
	@RIVAL		NVARCHAR(MAX) = NULL
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ClientStudy(ID_MASTER, ID_CLIENT, ID_CLAIM, DATE, ID_PLACE, ID_TEACHER, NEED, RECOMEND, NOTE, TEACHED, ID_TYPE, RIVAL, STATUS, UPD_DATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_CLIENT, ID_CLAIM, DATE, ID_PLACE, ID_TEACHER, NEED, RECOMEND, NOTE, TEACHED, ID_TYPE, RIVAL, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientStudy
			WHERE ID = @ID

		DECLARE @NEWID UNIQUEIDENTIFIER

		SELECT @NEWID = ID
		FROM @TBL

		UPDATE dbo.ClientStudy
		SET DATE		=	@DATE,
			ID_PLACE	=	@PLACE,
			ID_TEACHER	=	@TEACHER,
			NEED		=	@NEED,
			RECOMEND	=	@RECOMEND,
			NOTE		=	@NOTE,
			TEACHED		=	@TEACHED,
			ID_TYPE		=	@ID_TYPE,
			RIVAL		=	@RIVAL,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		UPDATE dbo.ClientStudyPeople
		SET ID_STUDY = @NEWID
		WHERE ID_STUDY = @ID

		UPDATE dbo.ClientStudySystem
		SET ID_STUDY = @NEWID
		WHERE ID_STUDY = @ID

		DECLARE @XML XML

		SET @XML = CAST(@PEOPLE AS XML)

		INSERT INTO dbo.ClientStudyPeople(ID_STUDY, SURNAME, NAME, PATRON, POSITION, NUM, GR_COUNT, ID_SERT_TYPE, SERT_COUNT, NOTE, ID_RDD_POS)
			SELECT
				@ID, SURNAME, NAME, PATRON, POSITION,
				CONVERT(SMALLINT, CASE WHEN NUM = '' THEN NULL ELSE NUM END),
				CONVERT(SMALLINT, CASE WHEN CNT = '' THEN NULL ELSE CNT END),
				CONVERT(UNIQUEIDENTIFIER, CASE WHEN SERT_TYPE = '' THEN NULL ELSE SERT_TYPE END),
				CONVERT(SMALLINT, CASE WHEN SERT_COUNT = '' THEN NULL ELSE SERT_COUNT END),
				NOTE,
				CONVERT(UNIQUEIDENTIFIER, CASE WHEN RDD_POS = '' THEN NULL ELSE RDD_POS END)
			FROM
				(
					SELECT
						c.value('./surname[1]', 'NVARCHAR(256)') AS SURNAME,
						c.value('./name[1]', 'NVARCHAR(256)') AS NAME,
						c.value('./patron[1]', 'NVARCHAR(256)') AS PATRON,
						c.value('./position[1]', 'NVARCHAR(256)') AS POSITION,
						c.value('./num[1]', 'NVARCHAR(16)') AS NUM,
						c.value('./count[1]', 'NVARCHAR(16)') AS CNT,
						c.value('./sert_type[1]', 'NVARCHAR(64)') AS SERT_TYPE,
						c.value('./sert_count[1]', 'NVARCHAR(16)') AS SERT_COUNT,
						c.value('./note[1]', 'NVARCHAR(MAX)') AS NOTE,
						c.value('./rdd_pos[1]', 'NVARCHAR(64)') AS RDD_POS
					FROM @XML.nodes('/root/people') a(c)
				) AS o_O

		INSERT INTO dbo.ClientStudySystem(ID_STUDY, ID_SYSTEM)
			SELECT @ID, ID
			FROM dbo.TableIDFromXML(@SYSTEMS)

		/*
		IF @CLAIM IS NOT NULL
		BEGIN
			EXEC dbo.CLIENT_STUDY_CLAIM_EXECUTE @CLAIM
		END
		*/

		IF @REPEAT IS NOT NULL
		BEGIN
			EXEC dbo.STUDY_CLAIM_INSERT @CLIENT, NULL, NULL, '', @PEOPLE, NULL, 1
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_UPDATE] TO rl_client_study_u;
GO