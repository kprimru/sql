USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_INSERT]
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
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT,
	@SYSTEMS	NVARCHAR(MAX) = NULL,
	@ID_TYPE	UNIQUEIDENTIFIER = NULL,
	@RIVAL		NVARCHAR(MAX) = NULL,
	@AGREEMENT  BIT = 1
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

		INSERT INTO dbo.ClientStudy(ID_CLIENT, ID_CLAIM, DATE, ID_PLACE, ID_TEACHER, NEED, RECOMEND, NOTE, TEACHED, ID_TYPE, RIVAL, AGREEMENT)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@CLIENT, @CLAIM, @DATE, @PLACE, @TEACHER, @NEED, @RECOMEND, @NOTE, @TEACHED, @ID_TYPE, @RIVAL, @AGREEMENT)

		SELECT @ID = ID
		FROM @TBL

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

		IF @CLAIM IS NOT NULL
		BEGIN
			EXEC dbo.STUDY_CLAIM_EXECUTE @CLAIM
		END

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
GRANT EXECUTE ON [dbo].[STUDY_INSERT] TO rl_client_study_i;
GO
