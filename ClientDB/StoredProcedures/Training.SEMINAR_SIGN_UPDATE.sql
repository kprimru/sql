USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@SCHEDULE	UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@SURNAME	VARCHAR(150),
	@NAME		VARCHAR(150),
	@PATRON		VARCHAR(150),
	@POS		VARCHAR(150),
	@PHONE		VARCHAR(150),
	@NOTE		VARCHAR(MAX),
	@RESERVED	BIT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		IF @RESERVED = 0
		BEGIN
			SELECT @SIGN = SP_ID
			FROM Training.SeminarSign
			WHERE SP_ID_SEMINAR = @SCHEDULE
				AND SP_ID_CLIENT = @CLIENT

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
				RAISERROR ('Ошибка записи о клиенте. Обратитесь к разработчику.', 10, 1)
				RETURN
			END

			UPDATE Training.SeminarSignPersonal
			SET SSP_ID_SIGN =	@SIGN,
				SSP_SURNAME	=	@SURNAME,
				SSP_NAME	=	@NAME,
				SSP_PATRON	=	@PATRON,
				SSP_POS		=	@POS,
				SSP_PHONE	=	@PHONE,
				SSP_NOTE	=	@NOTE
			WHERE SSP_ID = @ID
		END
		ELSE
		BEGIN
			UPDATE Training.SeminarReserve
			SET SR_ID_CLIENT	=	@CLIENT,
				SR_SURNAME		=	@SURNAME,
				SR_NAME			=	@NAME,
				SR_PATRON		=	@PATRON,
				SR_POS			=	@POS,
				SR_PHONE		=	@PHONE,
				SR_NOTE			=	@NOTE
			WHERE SR_ID = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_UPDATE] TO rl_training_u;
GO