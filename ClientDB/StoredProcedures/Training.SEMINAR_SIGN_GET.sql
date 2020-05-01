USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_GET]
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

		SELECT SP_ID_SEMINAR, SP_ID_CLIENT, SSP_SURNAME, SSP_NAME, SSP_PATRON, SSP_POS, SSP_PHONE, SSP_NOTE
		FROM
			Training.SeminarSignPersonal
			INNER JOIN Training.SeminarSign ON SSP_ID_SIGN = SP_ID
		WHERE SSP_ID = @ID

		UNION ALL

		SELECT NULL AS SP_ID_SEMINAR, SR_ID_CLIENT, SR_SURNAME, SR_NAME, SR_PATRON, SR_POS, SR_PHONE, SR_NOTE
		FROM
			Training.SeminarReserve
		WHERE SR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_GET] TO rl_training_r;
GO