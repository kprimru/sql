USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_RESERVE]
	@ID	UNIQUEIDENTIFIER OUTPUT
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

		INSERT INTO Training.SeminarReserve(SR_ID_SUBJECT, SR_ID_CLIENT, SR_SURNAME, SR_NAME, SR_PATRON, SR_POS, SR_PHONE, SR_NOTE)
			OUTPUT INSERTED.SR_ID INTO @TBL
			SELECT TSC_ID_TS, SP_ID_CLIENT, SSP_SURNAME, SSP_NAME, SSP_PATRON, SSP_POS, SSP_PHONE, SSP_NOTE
			FROM
				Training.SeminarSignPersonal
				INNER JOIN Training.SeminarSign ON SSP_ID_SIGN = SP_ID
				INNER JOIN Training.TrainingSchedule ON TSC_ID = SP_ID_SEMINAR
			WHERE SSP_ID = @ID

		DECLARE @SIGN	UNIQUEIDENTIFIER

		SELECT @SIGN = SSP_ID_SIGN
		FROM Training.SeminarSignPersonal
		WHERE SSP_ID = @ID

		DELETE FROM Training.SeminarSignPersonal WHERE SSP_ID = @ID

		IF NOT EXISTS
			(
				SELECT *
				FROM Training.SeminarSignPersonal
				WHERE SSP_ID_SIGN = @SIGN
			)
			DELETE FROM Training.SeminarSign WHERE SP_ID = @SIGN

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_RESERVE] TO rl_training_reserve;
GO
