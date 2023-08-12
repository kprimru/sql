USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[TRAINING_SCHEDULE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[TRAINING_SCHEDULE_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Training].[TRAINING_SCHEDULE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@SUBJECT	UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@LIMIT		SMALLINT = NULL
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

		UPDATE Training.TrainingSchedule
		SET TSC_ID_TS = @SUBJECT,
			TSC_DATE = @DATE,
			TSC_LIMIT = @LIMIT
		WHERE TSC_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[TRAINING_SCHEDULE_UPDATE] TO rl_training_i;
GO
