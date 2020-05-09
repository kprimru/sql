USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[WEB_PERSONAL_SEMINAR_CONFIRM]
	@ID			UNIQUEIDENTIFIER,
	@ADDRESS	NVARCHAR(128),
	@STATUS		BIT
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

		UPDATE Seminar.Personal
		SET CONFIRM_DATE	=	GETDATE(),
			CONFIRM_ADDRESS	=	@ADDRESS,
			CONFIRM_STATUS	=	@STATUS
		WHERE ID = @ID

		-- если кто-то отказался, то меняем ему статус на "отказался" и ставим статус "записан" первому из резервного списка
		IF @STATUS = 0
		BEGIN
			DECLARE @SCHEDULE UNIQUEIDENTIFIER

			SELECT @SCHEDULE = ID_SCHEDULE
			FROM Seminar.Personal
			WHERE ID = @ID

			EXEC Seminar.SCHEDULE_PERSONAL_CANCEL @ID, @SCHEDULE

			DECLARE @RESERVE UNIQUEIDENTIFIER

			SELECT TOP 1 @RESERVE = ID
			FROM Seminar.Personal
			WHERE ID_SCHEDULE = @SCHEDULE
				AND ID_STATUS = (SELECT ID FROM Seminar.Status WHERE INDX = 2)

			EXEC Seminar.SCHEDULE_PERSONAL_ACTIVE @RESERVE, @SCHEDULE
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
GRANT EXECUTE ON [Seminar].[WEB_PERSONAL_SEMINAR_CONFIRM] TO rl_seminar_web;
GO