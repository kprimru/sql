USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[MAILING_ERRORS_NOTIFY]
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

		DECLARE
			@Hours	SmallInt,
			@Cnt	Int,
			@Text	NVarChar(Max);

		SET @Hours = 2;

		SET @Cnt =
			(
				SELECT COUNT(*)
				FROM Common.MailingLog
				WHERE Status = 1
					AND Date >= DateAdd(Hour, -@Hours, GetDate())
			);

		IF @Cnt > 0 BEGIN
			SET @Text = N'За прошелдшие ' + Cast(@Hours AS NVarChar(20)) + N' часа возникло ' + Cast(@Cnt AS NVarChar(20)) + N' ошибок. Проверьте журнал отправленных сообщений.';

			EXEC Maintenance.MAIL_SEND @Text = @Text;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
