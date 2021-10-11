USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_WORK_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@CLAIM		UNIQUEIDENTIFIER,
	@TP			TINYINT,
	@DATE		DATETIME,
	@NOTE		NVARCHAR(MAX),
	@MET_DATE	DATETIME,
	@CALL_DATE	SMALLDATETIME,
	@CANCEL		BIT
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

		IF @ID IS NULL
			INSERT INTO dbo.ClientStudyClaimWork(ID_CLAIM, TP, DATE, NOTE, TEACHER)
				SELECT @CLAIM, @TP, @DATE, @NOTE, ORIGINAL_LOGIN()
		ELSE
		BEGIN
			INSERT INTO dbo.ClientStudyClaimWork(ID_MASTER, ID_CLAIM, TP, DATE, NOTE, TEACHER, STATUS, UPD_DATE, UPD_USER)
				SELECT @ID, ID_CLAIM, TP, DATE, NOTE, TEACHER, 2, UPD_DATE, UPD_USER
				FROM dbo.ClientStudyClaimWork
				WHERE ID = @ID

			UPDATE dbo.ClientStudyClaimWork
			SET TP = @TP,
				DATE = @DATE,
				NOTE = @NOTE,
				UPD_DATE = GETDATE(),
				UPD_USER = ORIGINAL_LOGIN()
			WHERE ID = @ID
		END

		IF (SELECT ID_TEACHER FROM dbo.ClientStudyClaim WHERE ID = @CLAIM) IS NULL
			UPDATE dbo.ClientStudyClaim
			SET ID_TEACHER = (SELECT TOP 1 TeacherID FROM dbo.TeacherTable WHERE TeacherLogin = ORIGINAL_LOGIN())
			WHERE ID = @CLAIM

		IF @MET_DATE IS NOT NULL
			UPDATE dbo.ClientStudyClaim
			SET MEETING_DATE = @MET_DATE,
				MEETING_NOTE = @NOTE,
				CALL_DATE	= NULL
			WHERE ID = @CLAIM

		IF @CALL_DATE IS NOT NULL
			UPDATE dbo.ClientStudyClaim
			SET CALL_DATE = @CALL_DATE,
				MEETING_DATE = NULL
			WHERE ID = @CLAIM

		IF @CANCEL = 1
			EXEC dbo.STUDY_CLAIM_CANCEL @CLAIM, @NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_WORK_SAVE] TO rl_client_study_claim_w;
GO
