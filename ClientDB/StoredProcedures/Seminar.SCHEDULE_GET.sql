USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SCHEDULE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[SCHEDULE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT ID, ID_SUBJECT, DATE, TIME, LIMIT, WEB, PERSONAL, QUESTIONS, INVITE_DATE, RESERVE_DATE, PROFILE_DATE, [Type_Id], [Link], [UseSubhostQuotes]
		FROM Seminar.Schedule a
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
GRANT EXECUTE ON [Seminar].[SCHEDULE_GET] TO rl_seminar_admin;
GO
