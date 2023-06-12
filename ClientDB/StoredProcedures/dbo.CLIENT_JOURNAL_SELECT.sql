USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_JOURNAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_JOURNAL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_JOURNAL_SELECT]
	@ID	INT
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

		SELECT a.ID, b.NAME, START, FINISH, NOTE, UPD_DATE, UPD_USER
		FROM
			dbo.ClientJournal a
			INNER JOIN dbo.Journal b ON a.ID_JOURNAL = b.ID
		WHERE ID_CLIENT = @ID AND STATUS = 1
		ORDER BY FINISH DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_JOURNAL_SELECT] TO rl_client_journal_r;
GO
