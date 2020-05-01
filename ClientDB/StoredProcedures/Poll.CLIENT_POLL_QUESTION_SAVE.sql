USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Poll].[CLIENT_POLL_QUESTION_SAVE]
	@POLL		UNIQUEIDENTIFIER,
	@QUESTION	UNIQUEIDENTIFIER,
	@TP			TINYINT,
	@ANSWER		NVARCHAR(MAX)
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

		IF ISNULL(@ANSWER, N'') <> N''
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
			DECLARE @ID UNIQUEIDENTIFIER

			INSERT INTO Poll.ClientPollQuestion(ID_POLL, ID_QUESTION)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@POLL, @QUESTION)

			SELECT @ID = ID FROM @TBL

			IF @TP = 0
				INSERT INTO Poll.ClientPollAnswer(ID_QUESTION, ID_ANSWER)
					SELECT @ID, CONVERT(UNIQUEIDENTIFIER, @ANSWER)
			ELSE IF @TP = 1
			BEGIN
				INSERT INTO Poll.ClientPollAnswer(ID_QUESTION, ID_ANSWER)
					SELECT @ID, ID
					FROM dbo.TableGUIDFromXML(@ANSWER)
			END
			ELSE IF @TP = 2
				INSERT INTO Poll.ClientPollAnswer(ID_QUESTION, TEXT_ANSWER)
					SELECT @ID, @ANSWER
			ELSE IF @TP = 3
				INSERT INTO Poll.ClientPollAnswer(ID_QUESTION, INT_ANSWER)
					SELECT @ID, CONVERT(INT, @ANSWER)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Poll].[CLIENT_POLL_QUESTION_SAVE] TO rl_client_poll_u;
GO