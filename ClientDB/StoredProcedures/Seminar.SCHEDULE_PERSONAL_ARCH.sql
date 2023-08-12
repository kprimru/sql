USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SCHEDULE_PERSONAL_ARCH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[SCHEDULE_PERSONAL_ARCH]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[SCHEDULE_PERSONAL_ARCH]
	@ID	UNIQUEIDENTIFIER
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

		INSERT INTO Seminar.Personal(ID_MASTER, ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, SURNAME, NAME, PATRON, POSITION, PHONE, NOTE, ID_STATUS, ADDRESS, MSG_SEND, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, SURNAME, NAME, PATRON, POSITION, PHONE, NOTE, ID_STATUS, ADDRESS, MSG_SEND, 2, UPD_DATE, UPD_USER
			FROM Seminar.Personal
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
