USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_CANCEL]
	@ID		UNIQUEIDENTIFIER,
	@STATUS	TINYINT = NULL
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

		DECLARE @SCHEDULE UNIQUEIDENTIFIER

		SELECT @SCHEDULE = SP_ID_SEMINAR
		FROM
			Training.SeminarSign
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE SSP_ID = @ID

		IF @STATUS = 0
			IF (
					SELECT COUNT(*)
					FROM
						Training.SeminarSign
						INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
					WHERE SP_ID_SEMINAR = @SCHEDULE AND SSP_CANCEL = 0
				) >=
				(
					SELECT TSC_LIMIT
					FROM Training.TrainingSchedule
					WHERE TSC_ID = @SCHEDULE
				)
			BEGIN
				RAISERROR ('”же записано максимальное количество участников. ћожно записать только в резерв.', 16, 1)
				RETURN
			END

		IF @STATUS IS NULL
			UPDATE Training.SeminarSignPersonal
			SET SSP_CANCEL = CASE SSP_CANCEL WHEN 1 THEN 0 ELSE 1 END
			WHERE SSP_ID = @ID
		ELSE
			UPDATE Training.SeminarSignPersonal
			SET SSP_CANCEL = @STATUS
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
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_CANCEL] TO rl_training_cancel;
GO
