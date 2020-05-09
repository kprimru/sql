USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_PERSONAL_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@SCHEDULE	UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@SURNAME	NVARCHAR(256),
	@NAME		NVARCHAR(256),
	@PATRON		NVARCHAR(256),
	@POSITION	NVARCHAR(256),
	@PHONE		NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
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

		IF @ID IS NULL
		BEGIN
			IF ((
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
				) AND @RESERVE = 0
			BEGIN
				RAISERROR ('”же записано максимальное количество участников. ћожно записать только в резерв.', 16, 1)
				RETURN
			END

			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			INSERT INTO Seminar.Personal(ID_SCHEDULE, ID_CLIENT, SURNAME, NAME, PATRON, POSITION, PHONE, NOTE, ID_STATUS)
				OUTPUT inserted.ID INTO @TBL
				SELECT @SCHEDULE, @CLIENT, @SURNAME, @NAME, @PATRON, @POSITION, @PHONE, @NOTE, ID
				FROM Seminar.Status
				WHERE INDX = 1 AND @RESERVE = 0 OR INDX = 2 AND @RESERVE = 1

			SELECT @ID = ID
			FROM @TBL
		END
		ELSE
		BEGIN
			EXEC Seminar.SCHEDULE_PERSONAL_ARCH @ID

			UPDATE Seminar.Personal
			SET ID_SCHEDULE =	@SCHEDULE,
				ID_CLIENT	=	@CLIENT,
				SURNAME		=	@SURNAME,
				NAME		=	@NAME,
				PATRON		=	@PATRON,
				POSITION	=	@POSITION,
				PHONE		=	@PHONE,
				NOTE		=	@NOTE
			WHERE ID = @ID
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
GRANT EXECUTE ON [Seminar].[SCHEDULE_PERSONAL_SAVE] TO rl_seminar_write;
GO