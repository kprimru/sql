USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[TRAINING_STUDY_SELECT]
	@ID		UNIQUEIDENTIFIER
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

		SELECT
			TSC_DATE, TS_NAME, SP_ID_CLIENT, ClientFullName, SSP_SURNAME, SSP_NAME, SSP_PATRON, SSP_POS,
			CONVERT(BIT,
				CASE SSP_STUDY
					WHEN 1 THEN 0
					ELSE
						CASE SSP_CANCEL
							WHEN 0 THEN 1
							ELSE 0
						END
				END
			) AS CHECKED,
			SSP_ID
		FROM
			Training.TrainingSchedule
			INNER JOIN Training.TrainingSubject ON TS_ID = TSC_ID_TS
			INNER JOIN Training.SeminarSign ON SP_ID_SEMINAR = TSC_ID
			INNER JOIN dbo.ClientTable ON ClientID = SP_ID_CLIENT
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE TSC_ID = @ID
		ORDER BY CHECKED DESC, ClientFullName, SSP_SURNAME, SSP_NAME, SSP_PATRON

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[TRAINING_STUDY_SELECT] TO rl_training_study;
GO
