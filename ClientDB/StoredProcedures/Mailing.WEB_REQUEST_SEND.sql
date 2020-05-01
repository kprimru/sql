USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Mailing].[WEB_REQUEST_SEND]
	@DistrS		VarChar(100),
	@Email		VarChar(100),
	@Msg		VarChar(512) OUTPUT
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

		DECLARE @HOST INT
		DECLARE @DISTR INT
		DECLARE @COMP TINYINT
		DECLARE @STATUS TINYINT

		EXEC Mailing.WEB_DISTR_CHECK @DISTRS, @MSG OUTPUT, @STATUS OUTPUT, @HOST OUTPUT, @DISTR	OUTPUT, @COMP OUTPUT

		IF @STATUS = 0 BEGIN
			INSERT INTO Mailing.Requests(HostID, Distr, Comp, OriginalEmail)
			SELECT @HOST, @DISTR, @COMP, @EMAIL;

			SET @MSG = 'Запрос на подписку успешно отправлен. Спасибо за обращение!';
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Mailing].[WEB_REQUEST_SEND] TO rl_mailing_web;
GO