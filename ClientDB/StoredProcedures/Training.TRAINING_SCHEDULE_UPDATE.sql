USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Training].[TRAINING_SCHEDULE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@SUBJECT	UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@LIMIT		SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Training.TrainingSchedule
	SET TSC_ID_TS = @SUBJECT, 
		TSC_DATE = @DATE,
		TSC_LIMIT = @LIMIT,
		TSC_LAST = GETDATE()
	WHERE TSC_ID = @ID
END