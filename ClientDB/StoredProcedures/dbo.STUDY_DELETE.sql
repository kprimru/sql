USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_DELETE]
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ClientStudy(ID_MASTER, ID_CLIENT, ID_CLAIM, DATE, ID_PLACE, ID_TEACHER, NEED, RECOMEND, NOTE, TEACHED, ID_TYPE, STATUS, UPD_DATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_CLIENT, ID_CLAIM, DATE, ID_PLACE, ID_TEACHER, NEED, RECOMEND, NOTE, TEACHED, ID_TYPE, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientStudy
			WHERE ID = @ID

		DECLARE @NEWID UNIQUEIDENTIFIER

		SELECT @NEWID = ID
		FROM @TBL

		UPDATE dbo.ClientStudy
		SET STATUS		=	3,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		UPDATE dbo.ClientStudyPeople
		SET ID_STUDY = @NEWID
		WHERE ID_STUDY = @ID

		INSERT INTO dbo.ClientStudyPeople(ID_STUDY, SURNAME, NAME, PATRON, POSITION, NUM, GR_COUNT, ID_SERT_TYPE, SERT_COUNT, NOTE, ID_RDD_POS)
			SELECT
				@ID, SURNAME, NAME, PATRON, POSITION, NUM, GR_COUNT, ID_SERT_TYPE, SERT_COUNT, NOTE, ID_RDD_POS
			FROM dbo.ClientStudyPeople
			WHERE ID_STUDY = @NEWID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_DELETE] TO rl_client_study_d;
GO