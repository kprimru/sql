USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_APPLY]
	@ID			UNIQUEIDENTIFIER,
	@TEACHER	INT = NULL,
	@NOTE		NVARCHAR(MAX) = NULL
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

		INSERT INTO dbo.ClientStudyClaim(ID_MASTER, ID_CLIENT, DATE, STUDY_DATE, CALL_DATE, NOTE, ID_TEACHER, TEACHER_NOTE, MEETING_DATE, MEETING_NOTE, STATUS, UPD_DATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_CLIENT, DATE, STUDY_DATE, CALL_DATE, NOTE, ID_TEACHER, TEACHER_NOTE, MEETING_DATE, MEETING_NOTE, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientStudyClaim
			WHERE ID = @ID

		DECLARE @NEWID UNIQUEIDENTIFIER

		SELECT @NEWID = ID
		FROM @TBL

		UPDATE dbo.ClientStudyClaim
		SET TEACHER_NOTE=	ISNULL(@NOTE, TEACHER_NOTE),
			ID_TEACHER  =   ISNULL(@TEACHER, ID_TEACHER),
			STATUS		= 1,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		UPDATE dbo.ClientStudyClaimPeople
		SET ID_CLAIM = @NEWID
		WHERE ID_CLAIM = @ID

		INSERT INTO dbo.ClientStudyClaimPeople(ID_CLAIM, SURNAME, NAME, PATRON, POSITION, PHONE, GR_COUNT, NOTE)
			SELECT
				@ID, SURNAME, NAME, PATRON, POSITION, PHONE, GR_COUNT, NOTE
			FROM dbo.ClientStudyClaimPeople
			WHERE ID_CLAIM = @NEWID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_APPLY] TO rl_client_study_claim_apply;
GO