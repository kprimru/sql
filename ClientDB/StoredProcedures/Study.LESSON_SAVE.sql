USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Study].[LESSON_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Study].[LESSON_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Study].[LESSON_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@TEACHER	NVARCHAR(128),
	@THEME		NVARCHAR(512),
	@NOTE		NVARCHAR(MAX)
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
		BEGIN
			INSERT INTO Study.Lesson(DATE, TEACHER, THEME, NOTE)
				VALUES(@DATE, @TEACHER, @THEME, @NOTE)
		END
		ELSE
		BEGIN
			INSERT INTO Study.Lesson(ID_MASTER, DATE, TEACHER, THEME, NOTE, STATUS, UPD_DATE, UPD_USER)
				SELECT @ID, DATE, TEACHER, THEME, NOTE, 2, UPD_DATE, UPD_USER
				FROM Study.Lesson
				WHERE ID = @ID

			UPDATE Study.Lesson
			SET DATE = @DATE,
				TEACHER = @TEACHER,
				THEME = @THEME,
				NOTE = @NOTE,
				UPD_DATE = GETDATE(),
				UPD_USER = ORIGINAL_LOGIN()
			WHERE ID = @ID
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
GRANT EXECUTE ON [Study].[LESSON_SAVE] TO rl_study_personal_u;
GO
