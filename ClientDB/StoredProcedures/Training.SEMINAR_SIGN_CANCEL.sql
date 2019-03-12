USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Training].[SEMINAR_SIGN_CANCEL]
	@ID		UNIQUEIDENTIFIER,
	@STATUS	TINYINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

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
END