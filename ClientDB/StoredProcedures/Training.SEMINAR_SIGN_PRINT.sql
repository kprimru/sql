USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_PRINT]
	@SCH_ID	UNIQUEIDENTIFIER
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

		DECLARE @SUBJ	UNIQUEIDENTIFIER

		SELECT @SUBJ = TSC_ID_TS
		FROM Training.TrainingSchedule
		WHERE TSC_ID = @SCH_ID

		SELECT
			ROW_NUMBER() OVER (ORDER BY ClientFullName, SSP_SURNAME, SSP_NAME, SSP_PATRON) AS RN,
			ClientFullName, ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') AS SSP_FIO,
			SSP_POS, SSP_PHONE, ServiceName, ManagerName,
			SSP_NOTE, CASE ISNULL(SSP_NOTE, '') WHEN '' THEN 0 ELSE 1 END AS SSP_NOTE_EXISTS
		FROM
			dbo.ClientView WITH(NOEXPAND)
			INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ClientID
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE SP_ID_SEMINAR = @SCH_ID AND SSP_CANCEL = 0
		ORDER BY ClientFullName, SSP_FIO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_PRINT] TO rl_training_r;
GO