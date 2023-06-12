USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Mailing].[WEB_MESSAGES_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Mailing].[WEB_MESSAGES_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Mailing].[WEB_MESSAGES_SELECT]
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

		SELECT PSEDO, TXT
		FROM Seminar.Messages

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Mailing].[WEB_MESSAGES_SELECT] TO rl_mailing_web;
GO
