USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@STUDY		SMALLDATETIME,
	@NOTE		NVARCHAR(MAX),
	@PEOPLE		NVARCHAR(MAX),
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

		INSERT INTO dbo.ClientStudyClaim(ID_MASTER, ID_CLIENT, DATE, STUDY_DATE, CALL_DATE, NOTE, ID_TEACHER, MEETING_DATE, MEETING_NOTE, STATUS, UPD_DATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_CLIENT, DATE, STUDY_DATE, CALL_DATE, NOTE, ID_TEACHER, MEETING_DATE, MEETING_NOTE, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientStudyClaim
			WHERE ID = @ID

		DECLARE @NEWID UNIQUEIDENTIFIER

		SELECT @NEWID = ID
		FROM @TBL

		UPDATE dbo.ClientStudyClaim
		SET DATE		=	@DATE,
			STUDY_DATE	=	@STUDY,
			NOTE		=	@NOTE,
			CALL_DATE	=	@CALL_DATE,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		UPDATE dbo.ClientStudyClaimPeople
		SET ID_CLAIM = @NEWID
		WHERE ID_CLAIM = @ID

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
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_UPDATE] TO rl_client_study_claim_w;
GO
