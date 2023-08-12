USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[TRAINING_STUDY_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[TRAINING_STUDY_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Training].[TRAINING_STUDY_SAVE]
	@CLIENT			INT,
	@DATE			SMALLDATETIME,
	@LESSON_PLACE	INT,
	@TEACHER		INT,
	@NOTE			VARCHAR(500),
	@SURNAME		VARCHAR(150),
	@NAME			VARCHAR(150),
	@PATRON			VARCHAR(150),
	@POS			VARCHAR(150),
	@ID				UNIQUEIDENTIFIER
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

		/* создать обучение у клиента */
		DECLARE @STUDY_ID	UNIQUEIDENTIFIER

		SELECT @STUDY_ID = ID
		FROM dbo.ClientStudy
		WHERE ID_CLIENT = @CLIENT
			AND DATE = @DATE
			AND ID_PLACE = @LESSON_PLACE
			AND ID_TEACHER = @TEACHER
			AND NOTE = @NOTE
			AND STATUS = 1

		IF @STUDY_ID IS NULL
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO dbo.ClientStudy(ID_CLIENT, DATE, ID_PLACE, ID_TEACHER, NOTE, TEACHED)
				OUTPUT inserted.ID INTO @TBL
				SELECT @CLIENT, @DATE, @LESSON_PLACE, @TEACHER, @NOTE, 1

			SELECT @STUDY_ID = ID
			FROM @TBL
		END


		INSERT INTO dbo.ClientStudyPeople(ID_STUDY, SURNAME, NAME, PATRON, POSITION, NUM)
			SELECT
				@STUDY_ID, @SURNAME, @NAME, @PATRON, @POS, 1

		UPDATE Training.SeminarSignPersonal
		SET SSP_STUDY = 1
		WHERE SSP_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[TRAINING_STUDY_SAVE] TO rl_training_study;
GO
