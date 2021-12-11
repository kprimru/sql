USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Poll].[CLIENT_POLL_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Poll].[CLIENT_POLL_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Poll].[CLIENT_POLL_SAVE]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@BLANK	UNIQUEIDENTIFIER,
	@NOTE	NVARCHAR(MAX),
	@ID_CALL	UNIQUEIDENTIFIER = NULL
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

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO Poll.ClientPoll(ID_CLIENT, DATE, ID_BLANK, NOTE, ID_CALL)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@CLIENT, @DATE, @BLANK, @NOTE, @ID_CALL)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Poll.ClientPoll
			SET DATE = @DATE,
				NOTE = @NOTE
			WHERE ID = @ID

			DELETE FROM Poll.ClientPollAnswer WHERE ID_QUESTION IN (SELECT ID FROM Poll.ClientPollQuestion WHERE ID_POLL = @ID)
			DELETE FROM Poll.ClientPollQuestion WHERE ID_POLL = @ID
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
GRANT EXECUTE ON [Poll].[CLIENT_POLL_SAVE] TO rl_client_poll_u;
GO
