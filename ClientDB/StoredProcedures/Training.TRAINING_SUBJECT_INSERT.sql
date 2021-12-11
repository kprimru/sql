USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[TRAINING_SUBJECT_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[TRAINING_SUBJECT_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Training].[TRAINING_SUBJECT_INSERT]
	@NAME	VARCHAR(100),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		INSERT INTO Training.TrainingSubject(TS_NAME)
			OUTPUT INSERTED.TS_ID INTO @TBL
			VALUES(@NAME)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[TRAINING_SUBJECT_INSERT] TO rl_training_subject_i;
GO
