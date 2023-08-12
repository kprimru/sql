USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_QUESTION_CONFIRM]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_QUESTION_CONFIRM]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[WEB_QUESTION_CONFIRM]
	@SCHEDULE	UNIQUEIDENTIFIER,
	@DISTR_S	NVARCHAR(256),
	@PSEDO		NVARCHAR(256),
	@EMAIL		NVARCHAR(256),
	@QUESTION	NVARCHAR(MAX),
	@ADDRESS	NVARCHAR(256),
	@STATUS		SMALLINT OUTPUT,
	@MSG		NVARCHAR(2048) OUTPUT
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

		DECLARE @Body	NVarChar(Max);
		DECLARE @HOST INT
		DECLARE @DISTR INT
		DECLARE @COMP TINYINT

		EXEC Seminar.WEB_DISTR_CHECK @SCHEDULE, @DISTR_S, @MSG OUTPUT, @STATUS OUTPUT, @HOST OUTPUT, @DISTR	OUTPUT, @COMP OUTPUT

		IF @STATUS = 0
		BEGIN

			INSERT INTO Seminar.Questions(ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, QUESTION, ADDRESS)
				SELECT
					@SCHEDULE, ID_CLIENT, @PSEDO, @EMAIL, @QUESTION, @ADDRESS
				FROM dbo.ClientDistrView WITH(NOEXPAND)
				WHERE HostID = @HOST
					AND DISTR = @DISTR
					AND COMP = @COMP

			IF @@ROWCOUNT = 0
			BEGIN
				SET @STATUS = 1
				SET @MSG = 'Вы не зарегистрированы в нашей базе как клиент.'
			END

			SELECT @Body = 'Поступил вопрос от клиента "' + ClientFullName + '", сотрудник "' + @PSEDO + ' (' + @EMAIL + ')".' + Char(10) + Char(13) +
				'Текст вопроса: ' + @QUESTION
			FROM dbo.ClientDistrView WITH(NOEXPAND)
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = ID_CLIENT
			WHERE HostID = @HOST
				AND DISTR = @DISTR
				AND COMP = @COMP

			EXEC [Common].[MAIL_SEND]
				@Recipients	= 'gazeta@kprim.ru;bateneva@bazis;denisov@bazis',
				--@Recipients	= 'denisov@bazis',
				@Subject	= 'Вопрос для семинара',
				@Body		= @Body;
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
GRANT EXECUTE ON [Seminar].[WEB_QUESTION_CONFIRM] TO rl_seminar_web;
GO
