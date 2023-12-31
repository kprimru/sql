USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_INSERT]
	@SCHEDULE	UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@SURNAME	VARCHAR(150),
	@NAME		VARCHAR(150),
	@PATRON		VARCHAR(150),
	@POS		VARCHAR(150),
	@PHONE		VARCHAR(150),
	@NOTE		VARCHAR(MAX),
	@RESERVE	BIT,
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @SIGN	UNIQUEIDENTIFIER
		DECLARE	@SUBJ	UNIQUEIDENTIFIER

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		SELECT @SIGN = SP_ID
		FROM Training.SeminarSign
		WHERE SP_ID_SEMINAR = @SCHEDULE
			AND SP_ID_CLIENT = @CLIENT

		SELECT @SUBJ = TSC_ID_TS
		FROM Training.TrainingSchedule
		WHERE TSC_ID = @SCHEDULE

		IF @RESERVE = 0
		BEGIN
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
				RAISERROR ('��� �������� ������������ ���������� ����������. ����� �������� ������ � ������.', 16, 1)
				RETURN
			END

			IF @SIGN IS NULL
			BEGIN
				INSERT INTO Training.SeminarSign(SP_ID_SEMINAR, SP_ID_CLIENT)
					OUTPUT INSERTED.SP_ID INTO @TBL
					VALUES(@SCHEDULE, @CLIENT)

				SELECT @SIGN = ID
				FROM @TBL
			END

			IF @SIGN IS NULL
			BEGIN
				RAISERROR ('������ ������ � �������. ���������� � ������������.', 16, 1)
				RETURN
			END

			DELETE FROM @TBL

			INSERT INTO Training.SeminarSignPersonal(SSP_ID_SIGN, SSP_SURNAME, SSP_NAME, SSP_PATRON, SSP_POS, SSP_PHONE, SSP_NOTE)
				OUTPUT INSERTED.SSP_ID INTO @TBL
				VALUES(@SIGN, @SURNAME, @NAME, @PATRON, @POS, @PHONE, @NOTE)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			INSERT INTO Training.SeminarReserve(SR_ID_SUBJECT, SR_ID_CLIENT, SR_SURNAME, SR_NAME, SR_PATRON, SR_POS, SR_PHONE, SR_NOTE)
				OUTPUT INSERTED.SR_ID INTO @TBL
				VALUES(@SUBJ, @CLIENT, @SURNAME, @NAME, @PATRON, @POS, @PHONE, @NOTE)

			SELECT @ID = ID FROM @TBL
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
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_INSERT] TO rl_training_i;
GO
