USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_JOURNAL_INSERT]
	@CLIENT		INT,
	@JOURNAL	UNIQUEIDENTIFIER,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@NOTE		VARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ClientJournal(ID_CLIENT, ID_JOURNAL, START, FINISH, NOTE)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@CLIENT, @JOURNAL, @BEGIN, @END, @NOTE)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_JOURNAL_INSERT] TO rl_client_journal_u;
GO