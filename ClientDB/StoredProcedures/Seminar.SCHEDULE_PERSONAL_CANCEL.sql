USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_PERSONAL_CANCEL]
	@ID			UNIQUEIDENTIFIER,
	@SCHEDULE	UNIQUEIDENTIFIER
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

		IF (SELECT INDX FROM Seminar.PersonalView WITH(NOEXPAND) WHERE ID = @ID) = 3
		BEGIN
			RAISERROR ('Сотрудник и так находится в списке отказников', 16, 1)
			RETURN
		END

		EXEC Seminar.SCHEDULE_PERSONAL_ARCH @ID

		UPDATE Seminar.Personal
		SET ID_SCHEDULE	=	@SCHEDULE,
			ID_STATUS	=	(SELECT ID FROM Seminar.Status WHERE INDX = 3),
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
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
GRANT EXECUTE ON [Seminar].[SCHEDULE_PERSONAL_CANCEL] TO rl_seminar_cancel;
GO