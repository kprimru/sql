USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_CLAIM_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_CLAIM_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_INSERT]
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@STUDY_DATE	SMALLDATETIME,
	@NOTE		NVARCHAR(MAX),
	@PEOPLE		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT,
	@REPEAT		BIT = 0,
	@MEETING	DATETIME = NULL,
	@CALL_DATE	SMALLDATETIME = NULL
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

		IF @DATE IS NULL
			SET @DATE = dbo.DateOf(GETDATE())

		DECLARE @TEACHER INT

		SELECT @TEACHER = TeacherID
		FROM dbo.TeacherTable
		WHERE TeacherLogin = ORIGINAL_LOGIN()

		INSERT INTO dbo.ClientStudyClaim(ID_CLIENT, DATE, STUDY_DATE, NOTE, REPEAT, MEETING_DATE, CALL_DATE, ID_TEACHER)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@CLIENT, @DATE, @STUDY_DATE, @NOTE, @REPEAT, @MEETING, @CALL_DATE, @TEACHER)

		SELECT @ID = ID
		FROM @TBL

		DECLARE @XML XML

		SET @XML = CAST(@PEOPLE AS XML)

		INSERT INTO dbo.ClientStudyClaimPeople(ID_CLAIM, SURNAME, NAME, PATRON, POSITION, PHONE, GR_COUNT, NOTE)
			SELECT
				@ID, SURNAME, NAME, PATRON, POSITION, PHONE,
				CONVERT(SMALLINT, CASE WHEN CNT = '' THEN NULL ELSE CNT END),
				NOTE
			FROM
				(
					SELECT
						c.value('./surname[1]', 'NVARCHAR(256)') AS SURNAME,
						c.value('./name[1]', 'NVARCHAR(256)') AS NAME,
						c.value('./patron[1]', 'NVARCHAR(256)') AS PATRON,
						c.value('./position[1]', 'NVARCHAR(256)') AS POSITION,
						c.value('./phone[1]', 'NVARCHAR(256)') AS PHONE,
						c.value('./count[1]', 'NVARCHAR(16)') AS CNT,
						c.value('./note[1]', 'NVARCHAR(MAX)') AS NOTE
					FROM @XML.nodes('/root/people') a(c)
				) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_INSERT] TO rl_client_study_claim_w;
GO
