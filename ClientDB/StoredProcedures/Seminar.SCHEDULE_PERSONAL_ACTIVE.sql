USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_PERSONAL_ACTIVE]
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

		IF (
				SELECT COUNT(*)
				FROM
					Seminar.PersonalView WITH(NOEXPAND)
				WHERE ID_SCHEDULE = @SCHEDULE AND INDX = 1
			) >=
			(
				SELECT LIMIT
				FROM Seminar.Schedule
				WHERE ID = @SCHEDULE
			)
		BEGIN
			RAISERROR ('”же записано максимальное количество участников. ћожно записать только в резерв.', 16, 1)
			RETURN
		END

		IF (SELECT INDX FROM Seminar.PersonalView WITH(NOEXPAND) WHERE ID = @ID) = 1
		BEGIN
			RAISERROR ('—отрудник и так находитс€ в активном списке', 16, 1)
			RETURN
		END

		EXEC Seminar.SCHEDULE_PERSONAL_ARCH @ID

		UPDATE Seminar.Personal
		SET ID_SCHEDULE	=	@SCHEDULE,
			ID_STATUS	=	(SELECT ID FROM Seminar.Status WHERE INDX = 1),
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
GRANT EXECUTE ON [Seminar].[SCHEDULE_PERSONAL_ACTIVE] TO rl_seminar_active;
GO
