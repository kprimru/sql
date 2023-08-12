USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_EMAIL_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_EMAIL_CHECK]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[WEB_EMAIL_CHECK]
	@EMAIL	NVARCHAR(64),
	@MSG	NVARCHAR(256) OUTPUT,
	@STATUS	SMALLINT OUTPUT
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

		SET @STATUS = 0
		SET @MSG = ''

		IF @EMAIL = ''
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Не введен e-mail'

			RETURN
		END

		IF CHARINDEX('@', @EMAIL) = 0
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'В адресе отсутствует символ "@"'

			RETURN
		END

		IF CHARINDEX(' ', @EMAIL) <> 0
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'В адресе присутстуют пробелы'

			RETURN
		END

		IF @EMAIL LIKE '%[а-я]%' OR @EMAIL LIKE '%[А-Я]%'
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'В адресе присутстуют русские буквы'

			RETURN
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
GRANT EXECUTE ON [Seminar].[WEB_EMAIL_CHECK] TO rl_seminar_web;
GO
