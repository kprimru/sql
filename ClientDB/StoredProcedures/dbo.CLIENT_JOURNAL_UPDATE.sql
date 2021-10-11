USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_JOURNAL_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@JOURNAL	UNIQUEIDENTIFIER,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@NOTE		VARCHAR(MAX)
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

		INSERT INTO dbo.ClientJournal(ID_MASTER, ID_CLIENT, ID_JOURNAL, START, FINISH, NOTE, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, ID_CLIENT, ID_JOURNAL, START, FINISH, NOTE, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientJournal
			WHERE ID = @ID

		UPDATE dbo.ClientJournal
		SET ID_JOURNAL	=	@JOURNAL,
			START		=	@BEGIN,
			FINISH		=	@END,
			NOTE		=	@NOTE,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
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
GRANT EXECUTE ON [dbo].[CLIENT_JOURNAL_UPDATE] TO rl_client_journal_u;
GO
