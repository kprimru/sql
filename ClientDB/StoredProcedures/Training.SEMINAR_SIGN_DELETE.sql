USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[SEMINAR_SIGN_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[SEMINAR_SIGN_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_DELETE]
	@ID			UNIQUEIDENTIFIER,
	@RESERVE	BIT
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

		IF @RESERVE = 0
		BEGIN
			DECLARE @SIGN	UNIQUEIDENTIFIER

			SELECT @SIGN = SSP_ID_SIGN
			FROM Training.SeminarSignPersonal
			WHERE SSP_ID = @ID

			DELETE
			FROM Training.SeminarSignPersonal
			WHERE SSP_ID = @ID

			IF NOT EXISTS
				(
					SELECT *
					FROM Training.SeminarSignPersonal
					WHERE SSP_ID_SIGN = @SIGN
				)
				DELETE FROM Training.SeminarSign WHERE SP_ID = @SIGN
		END
		ELSE
			DELETE FROM Training.SeminarReserve WHERE SR_ID = @ID

		DELETE FROM Training.SeminarSign WHERE NOT EXISTS (SELECT * FROM Training.SeminarSignPersonal WHERE SSP_ID_SIGN = SP_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_DELETE] TO rl_training_d;
GO
