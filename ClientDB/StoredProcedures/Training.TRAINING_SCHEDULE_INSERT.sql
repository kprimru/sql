USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Training].[TRAINING_SCHEDULE_INSERT]
	@SUBJECT	UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@LIMIT		SMALLINT,
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Training.TrainingSchedule(TSC_ID_TS, TSC_DATE, TSC_LIMIT)
			OUTPUT INSERTED.TSC_ID INTO @TBL
			VALUES(@SUBJECT, @DATE, @LIMIT)

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