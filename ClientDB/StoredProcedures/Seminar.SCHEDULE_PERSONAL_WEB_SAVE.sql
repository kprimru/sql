USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SCHEDULE_PERSONAL_WEB_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[SCHEDULE_PERSONAL_WEB_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_PERSONAL_WEB_SAVE]
	@SCHEDULE	UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@PSEDO		NVARCHAR(256),
	@EMAIL		NVARCHAR(256)
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

		INSERT INTO Seminar.Personal(ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, ID_STATUS)
			SELECT
				@SCHEDULE, @CLIENT, @PSEDO, @EMAIL,
				(
					SELECT ID
					FROM Seminar.Status
					WHERE INDX = 1
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[SCHEDULE_PERSONAL_WEB_SAVE] TO rl_seminar_write;
GO
