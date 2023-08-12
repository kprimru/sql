USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_CLAIM_WORK_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_CLAIM_WORK_DELETE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[STUDY_CLAIM_WORK_DELETE]
	@ID			UNIQUEIDENTIFIER
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

		INSERT INTO dbo.ClientStudyClaimWork(ID_MASTER, ID_CLAIM, TP, DATE, NOTE, TEACHER, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, ID_CLAIM, TP, DATE, NOTE, TEACHER, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientStudyClaimWork
			WHERE ID = @ID

		UPDATE dbo.ClientStudyClaimWork
		SET STATUS = 3,
			UPD_DATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_WORK_DELETE] TO rl_client_study_claim_d;
GO
