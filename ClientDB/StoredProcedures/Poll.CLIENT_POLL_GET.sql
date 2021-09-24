USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Poll].[CLIENT_POLL_GET]
	@ID	UNIQUEIDENTIFIER,
	@CALL	UNIQUEIDENTIFIER = NULL
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

		IF @CALL IS NOT NULL
			SELECT ID, DATE, ID_BLANK, NOTE
			FROM Poll.ClientPoll
			WHERE ID_CALL = @CALL
		ELSE
			SELECT ID, DATE, ID_BLANK, NOTE
			FROM Poll.ClientPoll
			WHERE ID = @ID

		/*
		SELECT ID, DATE, ID_BLANK, NOTE
		FROM Poll.ClientPoll
		WHERE (ID = @ID OR @ID IS NULL)
			AND (ID_CALL = @CALL OR @CALL IS NULL)
			AND (ID_CALL IS NOT NULL OR @ID IS NOT NULL)
			*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Poll].[CLIENT_POLL_GET] TO rl_client_poll_r;
GO
