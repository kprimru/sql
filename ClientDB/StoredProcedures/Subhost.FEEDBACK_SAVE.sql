USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[FEEDBACK_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[FEEDBACK_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[FEEDBACK_SAVE]
	@EMAIL	NVARCHAR(256),
	@NOTE	NVARCHAR(MAX)
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

		INSERT INTO Subhost.Feedback(EMAIL, NOTE)
			VALUES(@EMAIL, @NOTE)

		EXEC Maintenance.MAIL_SEND @NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[FEEDBACK_SAVE] TO rl_web_subhost;
GO
